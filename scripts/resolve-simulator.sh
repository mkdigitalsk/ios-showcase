#!/bin/bash
# Resolves a simulator name or UDID to the one simulator xcodebuild and simctl should target.
# A name matches the newest available iOS runtime, a booted one first; a UDID is taken as-is.
set -euo pipefail

usage() {
  cat <<USAGE >&2
usage: $(basename "$0") <name-or-udid> [--verbose]
  prints the UDID; --verbose prints "<udid> <name> <state>"
USAGE
}

[ $# -ge 1 ] || { usage; exit 2; }
target="$1"
verbose="${2:-}"

xcrun simctl list devices available -j | python3 -c '
import json, re, sys
target, verbose = sys.argv[1], sys.argv[2] == "--verbose"
devices = json.load(sys.stdin)["devices"]

def version(runtime):
    return tuple(int(p) for p in runtime.rsplit(".iOS-", 1)[-1].split("-") if p.isdigit())

if re.fullmatch(r"[0-9A-Fa-f-]{36}", target):
    matches = [((), d) for entries in devices.values() for d in entries if d["udid"].lower() == target.lower()]
else:
    matches = [(version(r), d) for r, entries in devices.items() if ".iOS-" in r for d in entries if d["name"] == target]
if not matches:
    print("no available simulator matches %r - xcrun simctl list devices available" % target, file=sys.stderr)
    sys.exit(1)
matches.sort(key=lambda m: (m[1]["state"] == "Booted", m[0]), reverse=True)
d = matches[0][1]
print(" ".join([d["udid"], d["name"], d["state"]]) if verbose else d["udid"])
' "$target" "$verbose"
