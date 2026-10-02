-- Text operations: positive byte counts retain, negative counts delete, strings insert.
-- Transform preserves both concurrent edits, including overlapping deletions.
local M = {}

function M.valid_text(text)
	local i = 1
	while i <= #text do
		local a, b, c, d = text:byte(i, i + 3)
		local length
		if a > 0 and a < 128 then
			length = 1
		elseif a >= 194 and a <= 223 and b and b >= 128 and b <= 191 then
			length = 2
		elseif a >= 224 and a <= 239 and b and c and c >= 128 and c <= 191 then
			local minimum, maximum = a == 224 and 160 or 128, a == 237 and 159 or 191
			if b >= minimum and b <= maximum then
				length = 3
			end
		elseif a >= 240 and a <= 244 and b and c and d and c >= 128 and c <= 191 and d >= 128 and d <= 191 then
			local minimum, maximum = a == 240 and 144 or 128, a == 244 and 143 or 191
			if b >= minimum and b <= maximum then
				length = 4
			end
		end
		assert(length, "Only valid UTF-8 text without NUL is supported")
		i = i + length
	end
end

local function append(op, part)
	if part == 0 or part == "" then
		return
	end
	local last = op[#op]
	if type(last) == type(part) and (type(part) == "string" or last * part > 0) then
		op[#op] = type(part) == "string" and (last .. part) or (last + part)
	else
		op[#op + 1] = part
	end
end

-- The final newline is a sentinel: no operation deletes it or inserts after it.
-- Neovim reports deleting the last line as removing "line\n"; merged with a
-- concurrent join of the previous newline, that would leave no final newline.
-- Move such edits before the sentinel with the same result; callers verify it.
function M.splice(length, start, removed, inserted)
	if start + removed == length and length > 0 then
		if inserted ~= "" then
			if removed == 0 then
				start, inserted = length - 1, "\n" .. inserted:sub(1, -2)
			else
				removed, inserted = removed - 1, inserted:sub(1, -2)
			end
		elseif removed > 0 and start > 0 then
			start = start - 1
		end
	end
	local op = {}
	append(op, start)
	append(op, inserted)
	append(op, -removed)
	append(op, length - start - removed)
	return op
end

function M.validate(op, length)
	assert(type(op) == "table" and #op <= 10000, "Invalid text operation")
	local consumed, inserted = 0, 0
	for _, part in ipairs(op) do
		if type(part) == "string" then
			M.valid_text(part)
			inserted = inserted + #part
		else
			assert(type(part) == "number" and part ~= 0 and part == math.floor(part), "Invalid byte count")
			consumed = consumed + math.abs(part)
		end
	end
	assert(consumed == length and inserted <= 1024 * 1024, "Invalid operation size")
	-- Ending in a retain keeps the sentinel; transforms and inverses preserve this.
	assert(length == 0 or (type(op[#op]) == "number" and op[#op] > 0), "Operation must keep the final newline")
end

function M.apply(text, op)
	M.validate(op, #text)
	local pieces, position, size = {}, 1, 0
	for _, part in ipairs(op) do
		if type(part) == "string" then
			pieces[#pieces + 1], size = part, size + #part
		else
			if part > 0 then
				pieces[#pieces + 1], size = text:sub(position, position + part - 1), size + part
			end
			position = position + math.abs(part)
			local next_byte = text:byte(position)
			assert(not next_byte or next_byte < 128 or next_byte >= 192, "Operation splits a UTF-8 character")
		end
		assert(size <= 1024 * 1024, "Shared document exceeds 1 MiB")
	end
	return table.concat(pieces)
end

function M.size(operation)
	local bytes = 0
	for _, part in ipairs(operation) do
		bytes = bytes + (type(part) == "string" and #part or 8)
	end
	return bytes
end

function M.inverse(text, op)
	local result, position = {}, 1
	for _, part in ipairs(op) do
		if type(part) == "string" then
			append(result, -#part)
		elseif part > 0 then
			append(result, part)
			position = position + part
		else
			append(result, text:sub(position, position - part - 1))
			position = position - part
		end
	end
	return result
end

function M.transform(left, right)
	local a, b, i, j = {}, {}, 1, 1
	local x, y = left[i], right[j]
	while x ~= nil or y ~= nil do
		if type(x) == "string" then
			append(a, x)
			append(b, #x)
			i, x = i + 1, left[i + 1]
		elseif type(y) == "string" then
			append(a, #y)
			append(b, y)
			j, y = j + 1, right[j + 1]
		else
			assert(x ~= nil and y ~= nil, "Operation lengths differ")
			local length = math.min(math.abs(x), math.abs(y))
			if x > 0 and y > 0 then
				append(a, length)
				append(b, length)
			elseif x < 0 and y > 0 then
				append(a, -length)
			elseif y < 0 and x > 0 then
				append(b, -length)
			end
			x = x + (x > 0 and -length or length)
			y = y + (y > 0 and -length or length)
			if x == 0 then
				i, x = i + 1, left[i + 1]
			end
			if y == 0 then
				j, y = j + 1, right[j + 1]
			end
		end
	end
	return a, b
end

-- Find a single replacement without splitting a UTF-8 character.
function M.difference(before, after)
	local first, old_end, new_end = 0, #before, #after
	while first < math.min(old_end, new_end) and before:byte(first + 1) == after:byte(first + 1) do
		first = first + 1
	end
	while first > 0 and (before:byte(first + 1) or 0) >= 128 and (before:byte(first + 1) or 0) < 192 do
		first = first - 1
	end
	while old_end > first and new_end > first and before:byte(old_end) == after:byte(new_end) do
		old_end, new_end = old_end - 1, new_end - 1
	end
	while old_end < #before and (before:byte(old_end + 1) or 0) >= 128 and before:byte(old_end + 1) < 192 do
		old_end, new_end = old_end + 1, new_end + 1
	end
	return first, old_end - first, after:sub(first + 1, new_end)
end

function M.position(text, offset)
	local prefix = text:sub(1, offset)
	local _, row = prefix:gsub("\n", "")
	return row, #(prefix:match("[^\n]*$") or "")
end

function M.move(offset, op)
	local input, output = 0, 0
	for _, part in ipairs(op) do
		if type(part) == "string" then
			output = output + #part
		elseif part > 0 then
			if offset < input + part then
				return output + offset - input
			end
			input, output = input + part, output + part
		else
			if offset < input - part then
				return output
			end
			input = input - part
		end
	end
	return output
end

return M
