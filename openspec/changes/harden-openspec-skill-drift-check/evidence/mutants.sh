#!/usr/bin/env bash
# Applies each of the 8 mutants of scripts/check-openspec-skills.sh that survived the self-tests
# in Principal QA's PR #38 review (#39 D2) to a scratch copy of the repository at HEAD, runs
# scripts/test-template-scripts.sh, and prints KILLED (a self-test that passes on the unmutated
# script fails) or SURVIVED. Self-tests that already fail unmutated (for example tests committed
# before the fix) are listed once and do not count as kills.
# Each mutant is a literal text replacement; a replacement that matches nothing is an ERROR.
# Usage: mutants.sh [repo-dir]   (default: the current repository). Writes only under mktemp.
set -uo pipefail
src=$(git -C "${1:-.}" rev-parse --show-toplevel)
work=$(mktemp -d); trap 'rm -rf "$work"' EXIT
names=(
  "1 matches-but-untracked branch disabled"
  "2 init failure ignored"
  "3 'generated no skill files' guard removed"
  "4 disagreeing-pins branch removed"
  "5 cleanup trap removed"
  "6 symlinked-folder guard removed"
  "7 temporary XDG_CONFIG_HOME/XDG_DATA_HOME removed"
  "8 exact MAJOR.MINOR.PATCH regex weakened to non-empty"
)
mutate() { # n file
  python3 - "$1" "$2" <<'PY'
import sys
n, path = sys.argv[1], sys.argv[2]
s = open(path).read()
m = {
 "1": ('elif untracked "$f"; then', 'elif false; then'),
 "2": ('run_openspec init --tools agents --profile core)', 'run_openspec init --tools agents --profile core || true)'),
 "3": ('if [ "$total" -eq 0 ]; then', 'if false; then'),
 "4": ('elif [ "$v" != "$pin" ]; then', 'elif false; then'),
 "5": ('trap \'rm -rf "$tmp"\' EXIT\n', ''),
 "6": ('[ -d "$p" ] && [ ! -L "$p" ]', '[ -d "$p" ]'),
 "7": ('env XDG_CONFIG_HOME="$tmp/xdg" XDG_DATA_HOME="$tmp/data" ', 'env '),
 "8": ('[[ ! "$v" =~ ^[0-9]+\\.[0-9]+\\.[0-9]+$ ]]', '[ -z "$v" ]'),
}[n]
if s.count(m[0]) != 1:
    sys.exit("pattern found %d times" % s.count(m[0]))
open(path, "w").write(s.replace(m[0], m[1]))
PY
}
echo "mutants.sh at $(git -C "$src" rev-parse HEAD)"
baseout=$("$src/scripts/test-template-scripts.sh" 2>&1)
echo "unmutated: $(tail -n1 <<<"$baseout")"
basefail=$(grep '^FAIL' <<<"$baseout" | sed -E 's/ \(.*$//')
[ -z "$basefail" ] || sed 's/^/           already failing unmutated: /' <<<"$basefail"
for entry in "${names[@]}"; do
  n=${entry%% *}; d="$work/m$n"
  git clone -q "$src" "$d"
  # Self-tests read the working tree, so carry over uncommitted script and test changes too.
  cp "$src/scripts/check-openspec-skills.sh" "$src/scripts/test-template-scripts.sh" "$d/scripts/"
  if ! why=$(mutate "$n" "$d/scripts/check-openspec-skills.sh" 2>&1); then echo "ERROR    mutant $entry: $why"; continue; fi
  out=$(cd "$d" && scripts/test-template-scripts.sh 2>&1)
  summary=$(tail -n1 <<<"$out")
  new=$(grep '^FAIL' <<<"$out" | while IFS= read -r l; do grep -qxF -- "$(sed -E 's/ \(.*$//' <<<"$l")" <<<"$basefail" || echo "$l"; done)
  if [ -n "$new" ]; then
    echo "KILLED   mutant $entry: $summary"; sed 's/^/           /' <<<"$new"
  else
    echo "SURVIVED mutant $entry: $summary"
  fi
done
