import argparse
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys


def tool(name):
    executable = shutil.which(name)
    if not executable:
        raise RuntimeError(f"Missing required tool: {name}")
    return executable


def output(command):
    result = subprocess.run(command, capture_output=True, text=True)
    if result.returncode:
        raise RuntimeError((result.stderr or result.stdout).strip() or f"Command failed: {command[0]}")
    return result.stdout


def workflows(directory):
    return {
        path.relative_to(directory).as_posix(): path
        for path in directory.glob("**/*")
        if path.is_file() and path.suffix in (".yml", ".yaml") and path.stem != "config"
    }


def pick(project):
    maestro = project / ".maestro"
    dev = workflows(maestro / "workflows")
    names = sorted(set(dev) | {
        path.name for path in maestro.glob("*")
        if path.is_file() and path.suffix in (".yml", ".yaml") and path.stem != "config"
    })
    if not names:
        raise RuntimeError(f"No Maestro workflows found in {maestro}")
    choices = [name + ("" if name in dev else "\t[no dev variant]") for name in names]
    environment = dict(os.environ, FZF_DEFAULT_OPTS="", FZF_DEFAULT_OPTS_FILE="")
    selected = subprocess.run(
        [tool("fzf"), "--no-multi", "--layout=reverse", "--prompt=Workflow > ",
         "--header=Current app session · Enter: run dev variant · Esc: cancel"],
        input="\n".join(choices), stdout=subprocess.PIPE, text=True, env=environment,
    )
    if selected.returncode in (1, 130):
        return None
    if selected.returncode:
        raise RuntimeError(f"Workflow picker failed with exit code {selected.returncode}")
    name = selected.stdout.rstrip("\n").split("\t")[0]
    if name not in dev:
        raise RuntimeError(f"No session-preserving dev variant for {name}. Add .maestro/workflows/{name} first.")
    return dev[name]


def first_running_device():
    devices = json.loads(output([tool("xcrun"), "simctl", "list", "devices", "--json"]))["devices"]
    for runtime, group in devices.items():
        if ".iOS-" in runtime:
            for device in group:
                if device["state"] == "Booted":
                    return device["udid"]
    raise RuntimeError("No running iOS simulator. Start one before running a Maestro workflow.")


def plan(args, flow, device):
    project = str(args.project)
    config = args.project / ".maestro/config.yaml"
    preview = Path.home() / ".agents/skills/rex-serve-sim/scripts/preview.py"
    for path in (config, preview):
        if not path.is_file():
            raise RuntimeError(f"Required file is missing: {path}")
    maestro = [tool("direnv"), "exec", project, "maestro", "test", "--device", device,
               "--platform", "ios", "--config", str(config), "-e",
               "MAESTRO_APP_ID=io.zepta.zcontrol.dev", str(flow)]
    return {
        "device": device,
        "maestro": maestro,
        "split": [tool("rex"), "split", "-s", args.session, "-b", args.anchor,
                  "--split=below", "--label", f"Maestro: {flow.stem}", "--focus=false",
                  "--keep-open", "--shell=none", "-c", project, "--json", "--", *maestro],
        "preview": [sys.executable, str(preview), "--device", device,
                    "--session", args.session, "--beside", args.anchor],
    }


def main():
    parser = argparse.ArgumentParser(description="Pick a Maestro dev workflow for the current app session.")
    parser.add_argument("--project", type=Path, required=True)
    parser.add_argument("--session", required=True)
    parser.add_argument("--anchor", required=True)
    parser.add_argument("--dry-run", action="store_true", help="Pick and print commands without starting Maestro or a preview")
    args = parser.parse_args()
    args.project = args.project.resolve()
    flow = pick(args.project)
    if flow is None:
        return 0
    commands = plan(args, flow, first_running_device())
    if args.dry_run:
        print(json.dumps(commands, indent=2))
        return 0
    output([tool("direnv"), "exec", str(args.project), "/bin/sh", "-c",
            "command -v maestro >/dev/null || { echo 'Maestro is unavailable in the project direnv environment' >&2; exit 1; }"])
    print(f"Running {flow.name} on {commands['device']}. Checking simulator preview…", flush=True)
    runner = json.loads(output(commands["split"]))
    print(json.dumps(runner), flush=True)
    preview = subprocess.run(commands["preview"], text=True, capture_output=True)
    output([tool("rex"), "move", "-s", args.session, runner["block_ids"][0], "below", args.anchor])
    if preview.returncode:
        raise RuntimeError("Maestro pane opened, but simulator preview failed: " + (preview.stdout or preview.stderr).strip())
    print(preview.stdout.strip())
    return 0


if __name__ == "__main__":
    try:
        sys.exit(main())
    except (RuntimeError, OSError, ValueError, KeyError, subprocess.SubprocessError) as error:
        print(f"Run Maestro workflow: {error}", file=sys.stderr)
        if sys.stdin.isatty():
            input("Press Enter to close…")
        sys.exit(1)
    except KeyboardInterrupt:
        sys.exit(0)
