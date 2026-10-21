#!/usr/bin/env bash
# Self-test for the template's check scripts and the qa-gate verdict filter.
# Each case states the expected exit code; any mismatch fails the run.
# Runs in scratch directories and changes nothing in this repository.
set -uo pipefail
root="$(git rev-parse --show-toplevel)"
scratch="$(mktemp -d)"
trap 'rm -rf "$scratch"' EXIT
fails=0; total=0

expect() { # expected-exit description command...
  local want=$1 name=$2; shift 2
  total=$((total + 1))
  "$@" >"$scratch/out" 2>&1; local got=$?
  if [ "$got" -eq "$want" ]; then echo "ok   $name"; else
    echo "FAIL $name (exit $got, expected $want)"; sed 's/^/     /' "$scratch/out"; fails=$((fails + 1)); fi
}

# A scratch repository with the scripts, for cases that need their own history or tree.
repo="$scratch/repo"
git init -q -b main "$repo"
git -C "$repo" config user.name test; git -C "$repo" config user.email test@example.invalid
git -C "$repo" config core.hooksPath /dev/null
cp -R "$root/scripts" "$repo/scripts"
git -C "$repo" add -A; git -C "$repo" commit -q -m "chore: base (#1)"
base=$(git -C "$repo" rev-parse HEAD)
in_repo() { (cd "$repo" && "$@"); }

# check-commits
git -C "$repo" commit -q --allow-empty -m "feat: add thing (#2)"
expect 0 "check-commits: conventional commit with issue reference" in_repo scripts/check-commits.sh "$base" HEAD 2-thing
git -C "$repo" commit -q --allow-empty -m "feat: no issue ref"
expect 1 "check-commits: missing issue reference" in_repo scripts/check-commits.sh "$base" HEAD 2-thing
expect 0 "check-commits: dependabot branch skips issue reference" in_repo scripts/check-commits.sh "$base" HEAD dependabot/github_actions/x
git -C "$repo" commit -q --allow-empty -m "updated stuff (#2)"
expect 1 "check-commits: not a conventional commit" in_repo scripts/check-commits.sh "$base" HEAD dependabot/github_actions/x

# check-em-dash
expect 0 "check-em-dash: clean tree" in_repo scripts/check-em-dash.sh
printf 'bad \xe2\x80\x94 line\n' > "$repo/note.md"
expect 1 "check-em-dash: em dash in a hand-written file" in_repo scripts/check-em-dash.sh
rm "$repo/note.md"

# check-workflows
mkdir -p "$repo/.github/workflows"
cp "$root"/.github/workflows/*.yml "$repo/.github/workflows/"
expect 0 "check-workflows: template workflows" in_repo scripts/check-workflows.sh
cat > "$repo/bad.yml" <<'YAML'
on:
  pull_request_target:
permissions: write-all
jobs:
  build:
    runs-on: windows-latest
    steps:
      - uses: actions/checkout@v4
YAML
expect 1 "check-workflows: unpinned, unbounded, privileged workflow" in_repo scripts/check-workflows.sh bad.yml

# slot.sh
expect 0 "slot: warns in the template repository" env GITHUB_REPOSITORY=OutcomefocusAi/repo-template "$root/scripts/slot.sh" lint
expect 1 "slot: fails in a derived repository" env GITHUB_REPOSITORY=someone/derived "$root/scripts/slot.sh" lint

# template-drift
cp "$root/template-manifest.txt" "$repo/"; cp "$root/SECURITY.md" "$repo/"
git -C "$repo" add -A; git -C "$repo" commit -q -m "chore: snapshot (#1)"
git clone -q "$repo" "$scratch/tpl"
expect 0 "template-drift: no drift" in_repo env TEMPLATE_DIR="$scratch/tpl" scripts/template-drift.sh test
echo "# local edit" >> "$repo/SECURITY.md"
expect 1 "template-drift: changed managed file" in_repo env TEMPLATE_DIR="$scratch/tpl" scripts/template-drift.sh test

# qa-gate verdict filter, extracted from the workflow so the test exercises the real text
filter=$(python3 - "$root/.github/workflows/qa-gate.yml" <<'PY'
import re, sys
s = open(sys.argv[1]).read()
print(re.search(r"--argjson allow \"\$allow_json\" '(.*?)'\)", s, re.S).group(1))
PY
)
sha=0123456789abcdef0123456789abcdef01234567
verdict() { jq -r -s --arg sha "$sha" --argjson allow '["AgileKnow23"]' "$filter"; }
c() { printf '{"user":{"login":"%s"},"updated_at":"%s","body":"%s"}\n' "$1" "$2" "$3"; }
check_verdict() { # expected description comments...
  local want=$1 name=$2; shift 2
  total=$((total + 1))
  local got; got=$(printf '%s\n' "$@" | verdict)
  if [ "$got" = "$want" ]; then echo "ok   qa-gate: $name"; else echo "FAIL qa-gate: $name (got '$got', expected '$want')"; fails=$((fails + 1)); fi
}
check_verdict "" "no verdict" "$(c AgileKnow23 1 'looks fine')"
check_verdict "SHIP" "SHIP for the head" "$(c AgileKnow23 1 "Independent QA by Principal QA: SHIP\\nhead $sha")"
check_verdict "" "SHIP for an older head" "$(c AgileKnow23 1 'Independent QA by Principal QA: SHIP\nhead fedcba9876543210fedcba9876543210fedcba98')"
check_verdict "" "SHIP from a non-allowlisted account" "$(c someone-else 1 "Independent QA by X: SHIP\\n$sha")"
check_verdict "SHIP-WITH-FIXES" "later SHIP-WITH-FIXES overrides SHIP" "$(c AgileKnow23 1 "Independent QA by Q: SHIP\\n$sha")" "$(c AgileKnow23 2 "Independent QA by Q: SHIP-WITH-FIXES\\n$sha")"
check_verdict "NO-SHIP" "later NO-SHIP overrides SHIP" "$(c AgileKnow23 1 "Independent QA by Q: SHIP\\n$sha")" "$(c AgileKnow23 2 "Independent QA by Q: NO-SHIP\\n$sha")"
check_verdict "SHIP" "CRLF first line" "$(c AgileKnow23 1 "Independent QA by Q: SHIP\\r\\n$sha")"

echo "test-template-scripts: $((total - fails))/$total passed"
[ "$fails" -eq 0 ]
