"""FLASH's optional Python-cell kernel; stdin/stdout carry JSON lines only."""

import asyncio
import contextlib
import json
import signal
import subprocess
import sys
import threading


def emit(kind, **fields):
    print(json.dumps({"type": kind, **fields}, ensure_ascii=True), flush=True)


async def main():
    try:
        import ipykernel  # noqa: F401
        from jupyter_client import AsyncKernelManager
    except ImportError:
        emit(
            "fatal",
            text=f"Install kernel tools in this Python: {sys.executable} -m pip install jupyter-client ipykernel",
        )
        return

    loop = asyncio.get_running_loop()
    requests = asyncio.Queue()
    main_task = asyncio.current_task()
    signal.signal(
        signal.SIGTERM,
        lambda *_: loop.call_soon_threadsafe(main_task.cancel),
    )

    def read_requests():
        try:
            for line in sys.stdin:
                request = json.loads(line)
                if request["action"] == "stop":
                    break
                loop.call_soon_threadsafe(requests.put_nowait, request)
        finally:
            # EOF/stop must also cancel startup rather than waiting for readiness.
            loop.call_soon_threadsafe(main_task.cancel)

    threading.Thread(target=read_requests, daemon=True).start()
    manager = AsyncKernelManager(kernel_name="python3")
    # Do not silently launch another environment's registered Python kernel.
    manager.kernel_spec.argv = [
        sys.executable,
        "-m",
        "ipykernel_launcher",
        "-f",
        "{connection_file}",
    ]
    client = None
    execution = None
    death = None

    async def watch_kernel():
        await loop.run_in_executor(None, manager.provisioner.process.wait)
        emit("fatal", text="Python kernel exited; restart it to run more cells")
        await requests.put({"action": "stop"})

    async def execute(request):
        chunks = []
        size = 0
        limited = False
        clear_pending = False

        def output(message):
            nonlocal size, limited, clear_pending
            kind, content = message["msg_type"], message["content"]
            if kind == "clear_output":
                if content.get("wait"):
                    clear_pending = True
                else:
                    chunks.clear()
                    size, limited = 0, False
                return
            if kind == "stream":
                text = content["text"]
            elif kind == "error":
                text = "\n".join(content["traceback"]) + "\n"
            elif kind in ("execute_result", "display_data", "update_display_data"):
                text = (
                    content.get("data", {}).get(
                        "text/plain", "[Rich output not rendered]"
                    )
                    + "\n"
                )
            else:
                return
            if clear_pending:
                chunks.clear()
                size, limited, clear_pending = 0, False, False
            encoded = text.encode("utf-8")
            remaining = max(0, 1024 * 1024 - size)
            if remaining:
                chunks.append(encoded[:remaining].decode("utf-8", errors="ignore"))
            size += min(len(encoded), remaining)
            limited = limited or len(encoded) > remaining

        try:
            reply = await client.execute_interactive(
                request["code"], allow_stdin=False, output_hook=output
            )
            if limited:
                chunks.append("\n[Output truncated at 1 MiB]\n")
            emit("done", text="".join(chunks), status=reply["content"]["status"])
        except asyncio.CancelledError:
            raise
        except Exception as error:  # noqa: BLE001 -- Report execution failures across the process boundary.
            emit("done", text=str(error), status="error")

    try:
        await manager.start_kernel(
            cwd=sys.argv[1], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL
        )
        death = asyncio.create_task(watch_kernel())
        client = manager.client()
        client.start_channels()
        await client.wait_for_ready(timeout=30)
        emit("ready", python=sys.executable)
        while True:
            request = await requests.get()
            action = request["action"]
            if action == "stop":
                break
            if action == "interrupt":
                await manager.interrupt_kernel()
            elif action == "run":
                if execution and not execution.done():
                    emit(
                        "error",
                        text="Kernel is busy; interrupt or wait before running another cell",
                    )
                else:
                    execution = asyncio.create_task(execute(request))
    except asyncio.CancelledError:
        pass
    except Exception as error:  # noqa: BLE001 -- Report kernel startup/transport failures to Neovim.
        emit("fatal", text=str(error))
    finally:
        if death:
            death.cancel()
            with contextlib.suppress(asyncio.CancelledError):
                await death
        if execution:
            execution.cancel()
            with contextlib.suppress(asyncio.CancelledError):
                await execution
        if manager.has_kernel:
            await manager.shutdown_kernel(now=True)
        if client:
            client.stop_channels()


if __name__ == "__main__":
    asyncio.run(main())
