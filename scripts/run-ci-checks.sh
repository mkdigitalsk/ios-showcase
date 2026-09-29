#!/bin/bash
# Local reflection of .github/workflows/ci.yml — same commands, same order.
set -euo pipefail
cd "$(dirname "$0")/.."

make format-check
git ls-files -z '*.sh' | xargs -0 shellcheck
make build
make test-design-system
make test-api
make test-unit
make test-snapshots
./scripts/run-e2e-suite.sh
