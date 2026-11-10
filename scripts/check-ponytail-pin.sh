#!/usr/bin/env bash
# Fails unless the vendored Ponytail skills' pin records agree and match the vendored files:
#   - each .agents/skills/ponytail*/SOURCE.md names a full 40-character commit ("Pinned commit"),
#     the same commit in its "File at that commit" link, and a git describe string
#     ("Upstream version"), all equal to the Ponytail row of the Sources table in TEMPLATE_SOURCE.md
#   - the SHA-256 recorded for SKILL.md and LICENSE in each SOURCE.md equals the file on disk
# The TEMPLATE_SOURCE.md row is the reference; each record that differs gets its own error.
# Usage: scripts/check-ponytail-pin.sh
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"
shopt -s nullglob

fail=0; hit=""
err() { echo "::error file=$1,line=$2::$3"; fail=1; }
one_match() { # file pattern description; sets hit to the single "line:text" match or reports
  local n
  hit=$(grep -nE -e "$2" -- "$1" || true)
  n=$(grep -c . <<<"$hit" || true)
  if [ "$n" -ne 1 ]; then err "$1" 1 "expected exactly one $3, found $n"; return 1; fi
}
sha_in() { grep -oE '(^|[^0-9a-f])[0-9a-f]{40}([^0-9a-f]|$)' <<<"$1" | grep -oE '[0-9a-f]{40}' | head -n 1 || true; }
describe_in() { grep -oE '`v[^`]*`' <<<"$1" | tail -n 1 | tr -d '`' || true; }

t=TEMPLATE_SOURCE.md
ref_sha=""; ref_desc=""; ref_line=1
if [ ! -f "$t" ]; then
  err "$t" 1 "$t not found"
elif one_match "$t" '^\| `\.agents/skills/ponytail/`' "Sources row for .agents/skills/ponytail/"; then
  ref_line=${hit%%:*}
  ref_sha=$(sha_in "${hit#*:}"); ref_desc=$(describe_in "${hit#*:}")
  [ -n "$ref_sha" ] || err "$t" "$ref_line" "Ponytail row names no full 40-character commit SHA"
  [ -n "$ref_desc" ] || err "$t" "$ref_line" "Ponytail row names no git describe string (\`v...\`)"
fi

dirs=(.agents/skills/ponytail*/)
[ "${#dirs[@]}" -gt 0 ] || err .agents/skills 1 "no .agents/skills/ponytail*/ folder found"
for d in "${dirs[@]}"; do
  d=${d%/}; s="$d/SOURCE.md"
  if [ ! -f "$s" ]; then err "$s" 1 "vendored skill folder $d has no SOURCE.md"; continue; fi

  if one_match "$s" '^\| Pinned commit \|' "Pinned commit row"; then
    line=${hit%%:*}; sha=$(sha_in "${hit#*:}")
    if [ -z "$sha" ]; then err "$s" "$line" "Pinned commit is not a full 40-character commit SHA"
    elif [ -n "$ref_sha" ] && [ "$sha" != "$ref_sha" ]; then
      err "$s" "$line" "Pinned commit $sha disagrees with $t line $ref_line ($ref_sha)"; fi
  fi
  if one_match "$s" '^\| File at that commit \|' "File at that commit row"; then
    line=${hit%%:*}; sha=$(grep -oE '/blob/[0-9a-f]{40}/' <<<"$hit" | grep -oE '[0-9a-f]{40}' || true)
    if [ -z "$sha" ]; then err "$s" "$line" "File at that commit link has no full 40-character commit SHA"
    elif [ -n "$ref_sha" ] && [ "$sha" != "$ref_sha" ]; then
      err "$s" "$line" "File at that commit link uses $sha, disagrees with $t line $ref_line ($ref_sha)"; fi
  fi
  if one_match "$s" '^\| Upstream version \|' "Upstream version row"; then
    line=${hit%%:*}; desc=$(describe_in "${hit#*:}")
    if [ -z "$desc" ]; then err "$s" "$line" "Upstream version names no git describe string (\`v...\`)"
    elif [ -n "$ref_desc" ] && [ "$desc" != "$ref_desc" ]; then
      err "$s" "$line" "git describe string $desc disagrees with $t line $ref_line ($ref_desc)"; fi
  fi
  for f in SKILL.md LICENSE; do
    if one_match "$s" "^\\| SHA-256 of \`$f\` \\|" "SHA-256 of $f row"; then
      line=${hit%%:*}; want=$(grep -oE '[0-9a-f]{64}' <<<"${hit#*:}" | head -n 1 || true)
      if [ ! -f "$d/$f" ]; then err "$d/$f" 1 "vendored file missing"; continue; fi
      got=$(sha256sum "$d/$f" | cut -d' ' -f1)
      if [ "$want" != "$got" ]; then
        err "$d/$f" 1 "SHA-256 is $got but $s line $line records '${want:-none}'"; fi
    fi
  done
done

if [ "$fail" -ne 0 ]; then exit 1; fi
echo "check-ponytail-pin: ${#dirs[@]} skill(s) agree on $ref_sha ($ref_desc)"
