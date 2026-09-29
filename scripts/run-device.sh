#!/bin/bash
# Build, install and launch the app on the one simulator `run.simulator` names.
set -euo pipefail

script="$(basename "${BASH_SOURCE[0]}")"
root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
props="$root/local.properties"
derived="$root/.build/derivedData"
scheme="TemplateIOS"

usage() {
  cat <<USAGE
Build the app, install it on the one simulator it is pinned to, and launch it there.

  $script [--configuration <name>] [--no-build] [--no-launch] [--dry-run]

  --configuration <name>  the build configuration — default Debug
  --no-build              install the .app the last build left, building nothing
  --no-launch             install only, and leave the app closed
  --dry-run               resolve the simulator and the last build, then stop — installs nothing
  -h, --help              this help

Reads from local.properties:
  run.device      must be true, or nothing runs
  run.simulator   the simulator's name ("iPhone 17 Pro Max") or its UDID; a name resolves to the
                  newest available runtime, a booted one first

Prints the simulator's UDID on stdout; every message goes to stderr.
USAGE
}

configuration="Debug"
build=true
launch=true
dry_run=false
while [ $# -gt 0 ]; do
  case "$1" in
    --configuration) configuration="${2:-}"; shift 2 ;;
    --no-build) build=false; shift ;;
    --no-launch) launch=false; shift ;;
    --dry-run) dry_run=true; build=false; shift ;;
    -h | --help) usage; exit 0 ;;
    *) echo "$script: unknown argument '$1'" >&2; usage >&2; exit 2 ;;
  esac
done

[ -n "$configuration" ] || { echo "$script: --configuration needs a name" >&2; exit 2; }
[ -f "$props" ] || { echo "$script: no local.properties at $props — copy local.properties.example" >&2; exit 2; }
command -v xcrun >/dev/null || { echo "$script: xcrun is missing — install Xcode" >&2; exit 1; }
command -v python3 >/dev/null || { echo "$script: python3 is missing — it reads simctl's device list" >&2; exit 1; }

prop() { sed -n "s/^[[:space:]]*$1[[:space:]]*=[[:space:]]*\(.*\)$/\1/p" "$props" | tail -1; }

[ "$(prop run.device)" = "true" ] || {
  echo "$script: run.device is not true in $props, so nothing installs on a simulator." >&2
  echo "Set run.device=true and run.simulator=<name or UDID> to enable it." >&2
  exit 1
}

target="$(prop run.simulator)"
[ -n "$target" ] || { echo "$script: no run.simulator in $props — it names the simulator this app runs on" >&2; exit 1; }

resolved="$("$root/scripts/resolve-simulator.sh" "$target" --verbose)" || exit 1
udid="${resolved%% *}"
rest="${resolved#* }"
name="${rest% *}"
state="${rest##* }"

if [ "$build" = true ]; then
  echo "building $scheme ($configuration) for ${name}…" >&2
  (cd "$root" && xcodegen generate >&2 && xcodebuild -project "$scheme.xcodeproj" -scheme "$scheme" -configuration "$configuration" \
    -destination "platform=iOS Simulator,id=$udid" -derivedDataPath "$derived" COMPILER_INDEX_STORE_ENABLE=NO build >&2)
fi

app="$derived/Build/Products/$configuration-iphonesimulator/$scheme.app"
[ -d "$app" ] || { echo "$script: no build at ${app#"$root/"} — run without --no-build" >&2; exit 1; }
bundle_id="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' "$app/Info.plist")"

if [ "$dry_run" = true ]; then
  echo "→ $name ($udid, $state): $bundle_id from ${app#"$root/"} — nothing installed" >&2
  echo "$udid"
  exit 0
fi

if [ "$state" != "Booted" ]; then
  echo "booting ${name}…" >&2
  xcrun simctl boot "$udid" >&2
  xcrun simctl bootstatus "$udid" -b >&2
fi

open -b com.apple.dt.Devices >/dev/null 2>&1 || open -a Simulator --args -CurrentDeviceUDID "$udid" >&2 || true

echo "installing $bundle_id on $name ($udid)…" >&2
xcrun simctl install "$udid" "$app" >&2

if [ "$launch" = true ]; then
  xcrun simctl launch "$udid" "$bundle_id" >&2
  echo "→ $name ($udid): $bundle_id installed and launched" >&2
else
  echo "→ $name ($udid): $bundle_id installed" >&2
fi
echo "next: xcrun simctl spawn $udid log stream --predicate 'subsystem == \"$bundle_id\"'   # its log" >&2
echo "$udid"
