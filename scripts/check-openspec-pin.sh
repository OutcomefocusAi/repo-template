#!/usr/bin/env bash
# Fails unless every record of the pinned OpenSpec version names the same exact version:
#   - the generatedBy stamp in each .agents/skills/openspec-*/SKILL.md
#   - each @fission-ai/openspec@<version> install line in .github/workflows/*.yml
#   - the OpenSpec rows of the Sources and Tool pins tables in TEMPLATE_SOURCE.md
# The CI install pin is the reference; each record that differs gets its own error.
# Usage: scripts/check-openspec-pin.sh
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"
shopt -s nullglob

fail=0
err() { echo "::error file=$1,line=$2::$3"; fail=1; }
files=(); lines=(); values=(); ref=""; hit=""
record() { # file line value [reference]
  if [[ ! "$3" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    err "$1" "$2" "OpenSpec version is not an exact MAJOR.MINOR.PATCH: '$3'"
  fi
  files+=("$1"); lines+=("$2"); values+=("$3")
  if [ -n "${4:-}" ] && [ -z "$ref" ]; then ref=$3; fi
}
one_match() { # file pattern description; sets hit to the single "line:text" match or reports
  # (runs in this shell, not a command substitution, so err can set fail)
  local n
  hit=$(grep -nE -e "$2" -- "$1" || true)
  n=$(grep -c . <<<"$hit" || true)
  if [ "$n" -ne 1 ]; then err "$1" 1 "expected exactly one $3, found $n"; return 1; fi
}

skills=(.agents/skills/openspec-*/SKILL.md)
[ "${#skills[@]}" -gt 0 ] || err .agents/skills 1 "no .agents/skills/openspec-*/SKILL.md found"
for f in "${skills[@]}"; do
  if one_match "$f" '^[[:space:]]+generatedBy:' "generatedBy line"; then
    record "$f" "${hit%%:*}" "$(sed -E 's/^[^:]*:[[:space:]]*generatedBy:[[:space:]]*"?([^"[:space:]]*)"?.*/\1/' <<<"$hit")"
  fi
done

ci=0
for f in .github/workflows/*.yml; do
  while IFS= read -r hit; do
    ci=$((ci + 1))
    record "$f" "${hit%%:*}" "$(sed -E 's/.*@fission-ai\/openspec@([^[:space:]]*).*/\1/' <<<"$hit")" ref
  done < <(grep -n '@fission-ai/openspec@' "$f" || true)
done
[ "$ci" -gt 0 ] || err .github/workflows 1 "no @fission-ai/openspec@<version> install line found"

t=TEMPLATE_SOURCE.md
if [ ! -f "$t" ]; then
  err "$t" 1 "$t not found"
else
  if one_match "$t" '^\| `\.agents/skills/openspec-\*/` \|' "Sources row for .agents/skills/openspec-*/"; then
    record "$t" "${hit%%:*}" "$(sed -nE 's/.*`@fission-ai\/openspec` ([^ ,]*).*/\1/p' <<<"$hit")"
  fi
  if one_match "$t" '^\| @fission-ai/openspec \|' "Tool pins row for @fission-ai/openspec"; then
    record "$t" "${hit%%:*}" "$(awk -F'|' '{gsub(/[[:space:]]/, "", $3); print $3}' <<<"${hit#*:}")"
  fi
fi

[ -n "$ref" ] || ref=${values[0]:-}
for i in "${!values[@]}"; do
  if [ "${values[$i]}" != "$ref" ]; then
    err "${files[$i]}" "${lines[$i]}" "OpenSpec version '${values[$i]}' disagrees with the CI pin '$ref'"
  fi
done

if [ "$fail" -ne 0 ]; then
  echo "check-openspec-pin: records found:"
  for i in "${!values[@]}"; do echo "  ${files[$i]}:${lines[$i]} ${values[$i]}"; done
  exit 1
fi
echo "check-openspec-pin: ${#values[@]} records agree on $ref"
