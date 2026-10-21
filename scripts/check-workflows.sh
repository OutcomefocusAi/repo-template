#!/usr/bin/env bash
# Hardening checks for GitHub Actions workflows:
#   - no pull_request_target trigger
#   - every remote action pinned to a 40-character commit SHA with a "# vX.Y.Z" comment
#   - top-level permissions set to contents: read
#   - every job sets timeout-minutes
#   - every job runs on a standard Linux runner (ubuntu-*)
# Usage: scripts/check-workflows.sh [workflow files...]  (default: .github/workflows/*.yml)
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

if [ "$#" -gt 0 ]; then files=("$@"); else files=(.github/workflows/*.yml); fi
fail=0
err() { echo "::error file=$1,line=$2::$3"; fail=1; }

for f in "${files[@]}"; do
  [ -f "$f" ] || { echo "check-workflows: no such file $f" >&2; exit 2; }

  while IFS=: read -r line _; do
    err "$f" "$line" "pull_request_target is not allowed"
  done < <(grep -n 'pull_request_target' "$f" || true)

  while IFS= read -r hit; do
    line=${hit%%:*}; text=${hit#*:}
    ref=$(sed -E 's/^[[:space:]-]*uses:[[:space:]]*//' <<<"$text")
    case "$ref" in ./*|docker://*) continue ;; esac
    if ! grep -Eq '^[A-Za-z0-9_.-]+/[A-Za-z0-9_./-]+@[0-9a-f]{40}[[:space:]]+#[[:space:]]*v[0-9]+(\.[0-9]+)*' <<<"$ref"; then
      err "$f" "$line" "action not pinned to a full commit SHA with a version comment: $ref"
    fi
  done < <(grep -nE '^[[:space:]-]*uses:' "$f" || true)

  if ! awk '/^permissions:/{getline n; if (n ~ /^  contents: read[[:space:]]*$/) ok=1} END{exit ok?0:1}' "$f"; then
    err "$f" 1 "top-level permissions must start with 'contents: read'"
  fi

  # Report jobs missing timeout-minutes or using a non-Linux runner.
  while IFS='|' read -r line job problem; do
    [ -n "$job" ] && err "$f" "$line" "job '$job' $problem"
  done < <(awk '
    function finish() {
      if (job != "") {
        if (!timeout) print jline "|" job "|has no timeout-minutes"
        if (runs !~ /^ubuntu-/) print jline "|" job "|must run on a standard Linux runner (ubuntu-*), found: " runs
      }
    }
    /^jobs:/ { injobs=1; next }
    injobs && /^[^ #]/ { finish(); injobs=0; job="" }
    injobs && /^  [A-Za-z0-9_-]+:[[:space:]]*$/ { finish(); job=$1; sub(":", "", job); jline=NR; timeout=0; runs=""; next }
    injobs && job != "" && /^    timeout-minutes:/ { timeout=1 }
    injobs && job != "" && /^    runs-on:/ { runs=$2 }
    END { finish() }
  ' "$f")
done

if [ "$fail" -ne 0 ]; then exit 1; fi
echo "check-workflows: ${#files[@]} workflow file(s) pass"
