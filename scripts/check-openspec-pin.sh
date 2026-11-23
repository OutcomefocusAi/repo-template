#!/usr/bin/env bash
# Fails unless every record of the pinned OpenSpec version names the same exact version:
#   - the generatedBy stamp in each .agents/skills/openspec-*/SKILL.md, where the pinned version
#     writes one (2.1.x writes none): at most one per skill, and on every skill or on none
#   - each @fission-ai/openspec@<version> install line in .github/workflows/*.yml and *.yaml
#   - the OpenSpec rows of the Sources and Tool pins tables in TEMPLATE_SOURCE.md
# The CI install pin is the reference; each record that differs gets its own error.
# Each workflow install line must also be exactly
#   npm install --global --no-fund --no-audit --before=YYYY-MM-DDTHH:MM:SSZ @fission-ai/openspec@<version>
# so npm resolves OpenSpec's dependency ranges only to versions published before that time: one
# cutoff, no other option that overrides or exempts it (a second --before, --enjoy-by,
# --min-release-age-exclude), and nothing after the package (||, ;, #). The cutoff must be a real
# UTC time from 2020-01-01T00:00:00Z up to now (npm silently ignores year 0000, and a future
# cutoff protects nothing), and must equal the cutoff in the Tool pins row of TEMPLATE_SOURCE.md.
# No workflow may set npm config through the environment (npm_config_* / NPM_CONFIG_*) or write
# it (npmrc, npm config set or edit, npm set), and each install line must sit in a literal
# `run: |` block, not continued from the line before with a trailing backslash.
# The generated-skills check (check-openspec-skills.sh) is what ties the skill content to the pin.
# Usage: scripts/check-openspec-pin.sh
# Backticks in the patterns below are literal Markdown, not command substitution.
# shellcheck disable=SC2016
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
stamped=""; first=""
for f in "${skills[@]}"; do
  hit=$(grep -nE -e '^[[:space:]]+generatedBy:' -- "$f" || true)
  n=$(grep -c . <<<"$hit" || true)
  if [ "$n" -gt 1 ]; then err "$f" 1 "expected at most one generatedBy line, found $n"; fi
  has=no; [ "$n" -eq 0 ] || has=yes
  if [ -z "$first" ]; then first=$f; stamped=$has
  elif [ "$has" != "$stamped" ]; then
    err "$f" 1 "generatedBy stamps must be on every generated skill or on none: this skill has stamp=$has, $first has stamp=$stamped"
  fi
  if [ "$n" -eq 1 ]; then
    record "$f" "${hit%%:*}" "$(sed -E 's/^[^:]*:[[:space:]]*generatedBy:[[:space:]]*"?([^"[:space:]]*)"?.*/\1/' <<<"$hit")"
  fi
done

ci=0; cutoffs=(); cutoff_at=(); now=$(date -u +%Y-%m-%dT%H:%M:%SZ)
run_block() { # file line: the install line must be inside a literal `run: |` block, not continued
  local f=$1 n=$2 i text sp
  if [ "$n" -gt 1 ] && sed -n "$((n - 1))p" "$f" | grep -qE '\\[[:space:]]*$'; then
    err "$f" "$n" "the OpenSpec install line continues the line before it (trailing backslash), so other options can join the command"
  fi
  # The block's parent is the nearest non-blank line above with less indentation; it must be the
  # run key with a literal block indicator (|, |- or |+), not a folded > or another key's block.
  text=$(sed -n "${n}p" "$f"); sp=${text%%[![:space:]]*}; sp=${#sp}
  for ((i = n - 1; i >= 1; i--)); do
    text=$(sed -n "${i}p" "$f")
    [[ "$text" =~ ^[[:space:]]*$ ]] && continue
    local lead=${text%%[![:space:]]*}
    if [ "${#lead}" -lt "$sp" ]; then
      [[ "$text" =~ ^[[:space:]]*(-[[:space:]]+)?run:[[:space:]]*\|[-+]?[[:space:]]*(#.*)?$ ]] && return 0
      break
    fi
  done
  err "$f" "$n" "the OpenSpec install line must be inside a literal run: | block (not a folded run: > block or another key's block), so no other line joins the command"
}
for f in .github/workflows/*.yml .github/workflows/*.yaml; do
  while IFS= read -r hit; do
    err "$f" "${hit%%:*}" "workflows must not set npm config through the environment (npm_config_* or NPM_CONFIG_*); it can override or exempt the OpenSpec install cutoff"
  done < <(grep -niE 'npm_config_' "$f" || true)
  while IFS= read -r hit; do
    err "$f" "${hit%%:*}" "workflows must not write npm config (npmrc, npm config set or edit, npm set); it can override or exempt the OpenSpec install cutoff"
  done < <(grep -niE 'npmrc|npm[[:space:]]+(config|c)[[:space:]]+(set|edit)|npm[[:space:]]+set([[:space:]]|$)' "$f" || true)
  while IFS= read -r hit; do
    ci=$((ci + 1))
    record "$f" "${hit%%:*}" "$(sed -E 's/.*@fission-ai\/openspec@([^[:space:]]*).*/\1/' <<<"$hit")" ref
    install='^[[:space:]]*npm install --global --no-fund --no-audit --before=([^[:space:]]*) @fission-ai/openspec@[^[:space:]]+[[:space:]]*$'
    if [[ ! "${hit#*:}" =~ $install ]]; then
      err "$f" "${hit%%:*}" "the OpenSpec install line must be exactly 'npm install --global --no-fund --no-audit --before=YYYY-MM-DDTHH:MM:SSZ @fission-ai/openspec@<version>' (one cutoff, no option that overrides or exempts it, nothing after the package)"
      continue
    fi
    c=${BASH_REMATCH[1]}; cutoffs+=("$c"); cutoff_at+=("$f:${hit%%:*}")
    run_block "$f" "${hit%%:*}"
    # The round trip through date accepts only a real time already written YYYY-MM-DDTHH:MM:SSZ;
    # npm only warns about an impossible date and then installs with no cutoff at all.
    if [ "$(date -u -d "$c" +%Y-%m-%dT%H:%M:%SZ 2>/dev/null)" != "$c" ]; then
      err "$f" "${hit%%:*}" "OpenSpec install cutoff '$c' is not a real UTC time written YYYY-MM-DDTHH:MM:SSZ"
    elif [[ "$c" < "2020-01-01T00:00:00Z" ]]; then
      # npm also ignores year 0000 with only a warning; any real cutoff is after OpenSpec 1.0.
      err "$f" "${hit%%:*}" "OpenSpec install cutoff '$c' is earlier than 2020-01-01T00:00:00Z"
    elif [[ "$c" > "$now" ]]; then
      err "$f" "${hit%%:*}" "OpenSpec install cutoff '$c' is later than now ($now), so it excludes nothing. Fix: use a past time after the pinned version's publish (npm view @fission-ai/openspec time --json)"
    fi
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
    row=$(sed -nE 's/.*`--before=([^`]*)`.*/\1/p' <<<"$hit")
    if [ -z "$row" ]; then
      err "$t" "${hit%%:*}" "the Tool pins row for @fission-ai/openspec does not record the --before cutoff used in CI"
    else
      for i in "${!cutoffs[@]}"; do
        [ "${cutoffs[$i]}" = "$row" ] || err "$t" "${hit%%:*}" "Tool pins row cutoff '$row' disagrees with the CI cutoff '${cutoffs[$i]}' at ${cutoff_at[$i]}"
      done
    fi
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
