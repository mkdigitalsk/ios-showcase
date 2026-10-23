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

# Green — record the tree proved, the index with the tracked edits beside it, for the push check in studio-seed's
# commit hook (rules/pre-commit-review.md § Push). A tree the list does not hold is one no gate ran on.
STASHED="$(git stash create)"
git rev-parse "${STASHED:-HEAD}^{tree}" >> "$(git rev-parse --git-common-dir)/ci-green"
