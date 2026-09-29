#!/usr/bin/env python3
"""Run a Maestro flow against the one simulator `run.simulator` names."""

import argparse
import os
import subprocess
import sys
import time
from pathlib import Path
from shutil import which
from typing import NoReturn

SCRIPT = Path(sys.argv[0])
ROOT = (SCRIPT.parent / "..").resolve()
PROPS = ROOT / "local.properties"

DRIVER_STARTUP_TIMEOUT = "90000"
"""Maestro gives the XCTest driver 15 s to come up by default; on a Mac also running an IDE and an
emulator, a cold simulator misses that and the run dies as "iOS driver not ready in time"."""

LOCATION_TIMEOUT = 15
"""`simctl location` has been seen to block forever on a simulator whose location service wedged
after a driver crash; a reboot of the simulator cleared it. Nothing here waits on it unbounded."""

DRIVER_PROCESS = "xcodebuild test-without-building.*maestro-driver"
"""Another iOS session's runner — another terminal, another agent — shows up as an xcodebuild test run
of the Maestro driver, and it brings this session's XCTest driver down mid-flow."""
OTHER_SESSION_TRIES = 30
OTHER_SESSION_INTERVAL = 2

EPILOG = """Reads from local.properties:
  run.device            must be true, or nothing runs — the same switch scripts/run-device.sh reads
  run.simulator         the simulator's name ("iPhone 17 Pro Max") or UDID; a name takes the newest
                        available runtime, a booted one first
  e2e.flows             where the flows live, relative to the repo — default .maestro
  e2e.locale            pinned for the run and restored after — AppleLanguages + AppleLocale
  e2e.location          a position as "<lat>,<lon>", set through simctl and cleared after
  e2e.appId             the bundle id, needed only by --no-location
  e2e.exclude-tags      comma-separated tags skipped by default — needs-api for a run without a server
  e2e.account.email     the account a flow signs in as, passed to maestro as E2E_EMAIL /
  e2e.account.password  E2E_PASSWORD — so no credential is written into a flow

Install the app first — this runs what is on the simulator and never builds:
  scripts/run-device.sh --no-launch"""


def say(message: str) -> None:
    print(message, file=sys.stderr)


def die(message: str, *hints: str, code: int = 1) -> NoReturn:
    say(f"{SCRIPT.name}: {message}")
    for hint in hints:
        say(hint)
    raise SystemExit(code)


def read_properties(path: Path) -> dict[str, str]:
    values: dict[str, str] = {}
    if not path.is_file():
        return values
    for line in path.read_text().splitlines():
        line = line.strip()
        if not line or line.startswith("#") or "=" not in line:
            continue
        key, _, value = line.partition("=")
        values[key.strip()] = value.strip()
    return values


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        prog=SCRIPT.name,
        description="Run a Maestro UI flow on the one iOS simulator this app is pinned to.",
        epilog=EPILOG,
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )
    parser.add_argument(
        "--flow", help="flow file or directory, relative to the repo; default: e2e.flows, else .maestro"
    )
    parser.add_argument(
        "--keep-location", action="store_true", help="leave the simulated position in place after the run"
    )
    parser.add_argument(
        "--clear-location", action="store_true", help="clear the simulated position and exit, running no flow"
    )
    parser.add_argument(
        "--no-location",
        action="store_true",
        help="run with no position at all — clears any simulated one and revokes the app's location "
        "permission for the run, for a flow whose subject is the app without one",
    )
    parser.add_argument(
        "maestro_args",
        nargs="*",
        metavar="-- <maestro args…>",
        help="everything after -- is passed to maestro unchanged",
    )
    return parser


class Simulator:
    def __init__(self, udid: str, target: str) -> None:
        self.udid = udid
        self.target = target

    def defaults(self, *args: str) -> subprocess.CompletedProcess:
        return subprocess.run(
            ["xcrun", "simctl", "spawn", self.udid, "defaults", *args], text=True, capture_output=True, check=False
        )

    def location(self, *args: str) -> int:
        try:
            done = subprocess.run(
                ["xcrun", "simctl", "location", self.udid, *args],
                capture_output=True,
                check=False,
                timeout=LOCATION_TIMEOUT,
            )
        except subprocess.TimeoutExpired:
            say(
                f"{SCRIPT.name}: simctl location hangs on {self.target} ({self.udid}) — shut it down and boot it again:"
            )
            say(f"  xcrun simctl shutdown {self.udid}")
            return 124
        return done.returncode

    def set_locale(self, locale: str) -> None:
        self.defaults("write", "-g", "AppleLanguages", "-array", locale)
        self.defaults("write", "-g", "AppleLocale", "-string", locale.replace("-", "_"))

    def privacy(self, action: str, app_id: str) -> None:
        subprocess.run(
            ["xcrun", "simctl", "privacy", self.udid, action, "location", app_id], capture_output=True, check=False
        )


def resolve_simulator(target: str) -> tuple[str, str]:
    resolver = ROOT / "scripts" / "resolve-simulator.sh"
    done = subprocess.run([str(resolver), target, "--verbose"], text=True, capture_output=True, check=False)
    if done.returncode != 0:
        die(done.stderr.strip() or f"no available simulator matches '{target}'")
    udid, _, rest = done.stdout.strip().partition(" ")
    return udid, rest.rsplit(" ", 1)[-1]


def open_simulator_ui(udid: str) -> None:
    shown = subprocess.run(["open", "-b", "com.apple.dt.Devices"], capture_output=True, check=False)
    if shown.returncode == 0:
        return
    subprocess.run(["open", "-a", "Simulator", "--args", "-CurrentDeviceUDID", udid], capture_output=True, check=False)


def other_session() -> str:
    found = subprocess.run(["pgrep", "-f", DRIVER_PROCESS], text=True, capture_output=True, check=False).stdout.split()
    return found[0] if found else ""


def main() -> None:
    args = build_parser().parse_args()
    if not PROPS.is_file():
        die(f"no local.properties at {PROPS} — copy local.properties.example", code=2)
    props = read_properties(PROPS)

    if props.get("run.device") != "true":
        die(
            "run.device is not true in local.properties, so nothing runs on a simulator.",
            "Set run.device=true and run.simulator=<name or UDID> to enable it.",
        )
    target = props.get("run.simulator", "")
    if not target:
        die("no run.simulator in local.properties — it names the simulator this app runs on.")

    flow_arg = args.flow or props.get("e2e.flows") or ".maestro"
    flow = Path(flow_arg) if Path(flow_arg).is_absolute() else ROOT / flow_arg
    starts_session = not args.clear_location
    if starts_session and not flow.exists():
        die(f"no flow at {flow}")

    os.environ["PATH"] = f"{os.environ['PATH']}:{Path.home()}/.maestro/bin"
    os.environ["MAESTRO_CLI_NO_ANALYTICS"] = "1"
    os.environ.setdefault("MAESTRO_DRIVER_STARTUP_TIMEOUT", DRIVER_STARTUP_TIMEOUT)
    if which("maestro") is None:
        die("maestro is not installed.", "Install it with: curl -Ls https://get.maestro.mobile.dev | bash")
    if which("xcrun") is None:
        die("xcrun is missing — install Xcode.")

    if starts_session:
        other = other_session()
        for _ in range(OTHER_SESSION_TRIES):
            if not other:
                break
            time.sleep(OTHER_SESSION_INTERVAL)
            other = other_session()
        if other:
            die(
                f"another iOS Maestro session is running (pid {other}) — wait for it; two of them kill each other's driver."
            )

    udid, state = resolve_simulator(target)
    simulator = Simulator(udid, target)
    if state != "Booted":
        say(f"booting {target} ({udid})…")
        subprocess.run(["xcrun", "simctl", "boot", udid], check=False)
        subprocess.run(["xcrun", "simctl", "bootstatus", udid, "-b"], capture_output=True, check=False)
    open_simulator_ui(udid)

    if args.clear_location:
        simulator.location("clear")
        say(f"{target} ({udid}): simulated position cleared")
        raise SystemExit(0)

    locale = props.get("e2e.locale", "")
    location = "" if args.no_location else props.get("e2e.location", "")
    restore_permission_for = ""
    if args.no_location:
        if simulator.location("clear") != 0:
            raise SystemExit(1)
        app_id = props.get("e2e.appId", "")
        if not app_id:
            die("--no-location needs e2e.appId in local.properties — the bundle id whose permission is revoked")
        subprocess.run(["xcrun", "simctl", "terminate", udid, app_id], capture_output=True, check=False)
        simulator.privacy("revoke", app_id)
        restore_permission_for = app_id

    original_languages = original_locale = ""
    if locale:
        original_languages = simulator.defaults("read", "-g", "AppleLanguages").stdout.replace("\n", "")
        original_locale = simulator.defaults("read", "-g", "AppleLocale").stdout.strip()
        simulator.set_locale(locale)
    if location and simulator.location("set", location) != 0:
        raise SystemExit(1)

    try:
        code = run_maestro(target, udid, flow, props, args)
    finally:
        if locale:
            if original_languages:
                simulator.defaults("write", "-g", "AppleLanguages", original_languages)
            else:
                simulator.defaults("delete", "-g", "AppleLanguages")
            if original_locale:
                simulator.defaults("write", "-g", "AppleLocale", "-string", original_locale)
            else:
                simulator.defaults("delete", "-g", "AppleLocale")
        if location and not args.keep_location:
            simulator.location("clear")
        if restore_permission_for:
            simulator.privacy("grant", restore_permission_for)
    raise SystemExit(code)


def account_arguments(props: dict[str, str]) -> list[str]:
    """The account as maestro `-e` variables, so the credential stays in local.properties — a flow is a tracked file."""
    arguments: list[str] = []
    for name, key in (("E2E_EMAIL", "e2e.account.email"), ("E2E_PASSWORD", "e2e.account.password")):
        value = props.get(key, "")
        if value:
            arguments += ["-e", f"{name}={value}"]
    return arguments


def run_maestro(target: str, udid: str, flow: Path, props: dict[str, str], args: argparse.Namespace) -> int:
    command = ["maestro", "--device", udid, "test"]
    exclude_tags = props.get("e2e.exclude-tags", "")
    if exclude_tags:
        command += ["--exclude-tags", exclude_tags]
    command += account_arguments(props)
    command += [str(flow), *args.maestro_args]
    say(f"{target} ({udid}): {flow.relative_to(ROOT) if flow.is_relative_to(ROOT) else flow}")
    return subprocess.run(command, check=False).returncode


if __name__ == "__main__":
    main()
