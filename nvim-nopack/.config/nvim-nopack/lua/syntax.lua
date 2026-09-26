-- =========================================
-- ========= TREESITTER / SYNTAX =========
-- =========================================
-- 설치본에 포함된 언어 파서가 있으면 내장 Treesitter를 사용합니다.
-- 없으면 기본 syntax를 유지하며 외부 파서·쿼리 다운로드는 하지 않습니다.
vim.api.nvim_create_autocmd("FileType", {
	callback = function(args)
		if vim.bo[args.buf].buftype ~= "" or vim.b[args.buf].nopack_large_file then
			return
		end
		local lang = vim.treesitter.language.get_lang(vim.bo[args.buf].filetype)
		if lang and pcall(vim.treesitter.language.add, lang) then
			pcall(vim.treesitter.start, args.buf, lang)
		end
	end,
})
