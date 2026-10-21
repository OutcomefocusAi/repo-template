#!/usr/bin/env bash
# Usage: scripts/template-drift.sh <template-tag>
# Lists template-managed files (template-manifest.txt) that differ from the template at
# <template-tag>, and exits 1 if any differ. Changes nothing in this repository.
# TEMPLATE_DIR=<path> compares against a local checkout instead of fetching (for testing).
set -euo pipefail

tag="${1:?usage: scripts/template-drift.sh <template-tag>}"
repo="${TEMPLATE_REPO:-OutcomefocusAi/repo-template}"
root="$(git rev-parse --show-toplevel)"

if [[ -n "${TEMPLATE_DIR:-}" ]]; then
  src="$TEMPLATE_DIR"
else
  tmp="$(mktemp -d)"
  trap 'rm -rf "$tmp"' EXIT
  gh repo clone "$repo" "$tmp/template" -- --quiet --depth 1 --branch "$tag" >/dev/null 2>&1 \
    || { echo "template-drift: could not fetch $repo at $tag" >&2; exit 2; }
  src="$tmp/template"
fi

mapfile -t paths < <(grep -v -e '^#' -e '^[[:space:]]*$' "$src/template-manifest.txt")

list() { # tracked files under the manifest paths, or all files when DIR is not a git checkout
  (
    cd "$1" || exit 1
    if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
      git ls-files -- "${paths[@]}"
    else
      find "${paths[@]}" -type f 2>/dev/null
    fi
  ) | sort -u
}

differ=0
while IFS= read -r f; do
  if [[ ! -f "$root/$f" ]]; then
    echo "missing:  $f"; differ=1
  elif [[ ! -f "$src/$f" ]]; then
    echo "extra:    $f"; differ=1
  elif ! cmp -s "$root/$f" "$src/$f"; then
    echo "differs:  $f"; differ=1
  fi
done < <({ list "$src"; list "$root"; } | sort -u)

if [[ $differ -eq 0 ]]; then
  echo "template-drift: nothing differs from $repo at $tag"
fi
exit "$differ"
