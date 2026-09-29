#!/bin/bash
# Runs the Maestro suite on every configured app when local.properties sets e2e.auto-run=true — the gate's
# last step, and a no-op wherever the file is absent, CI included.
set -euo pipefail
cd "$(dirname "$0")/.."

case "${1:-}" in
  -h | --help) echo "usage: scripts/run-e2e-suite.sh   (no arguments; reads local.properties)"; exit 0;;
esac

if [ "$(sed -n 's/^e2e\.auto-run=//p' local.properties 2>/dev/null)" != "true" ]; then
  echo "e2e.auto-run is not true in local.properties — the suite stays out of this run" >&2
  exit 0
fi

./scripts/run-e2e.py
