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
good_head='on: [push]
concurrency:
  group: x
permissions:
  contents: read
jobs:
  build:
    runs-on: ubuntu-24.04
    timeout-minutes: 5
    steps:'
printf '%s\n      - run: echo ok\n' "$good_head" > "$repo/ok.yml"
expect 0 "check-workflows: minimal hardened workflow" in_repo scripts/check-workflows.sh ok.yml
printf '%s\n      - {uses: actions/checkout@v4}\n' "$good_head" > "$repo/flow.yml"
expect 1 "check-workflows: flow-style uses mapping" in_repo scripts/check-workflows.sh flow.yml
sed 's/^  contents: read$/  contents: read\n  issues: write/' "$repo/ok.yml" > "$repo/extra.yml"
expect 1 "check-workflows: extra top-level write scope" in_repo scripts/check-workflows.sh extra.yml
grep -v -e '^concurrency:' -e '^  group: x' "$repo/ok.yml" > "$repo/noconc.yml"
expect 1 "check-workflows: missing concurrency" in_repo scripts/check-workflows.sh noconc.yml

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

# qa-gate verdict filter, extracted from the workflow so the tests exercise the real text.
# Items are shaped like the workflow's API stage: comments and reviews with user, body,
# created_at, updated_at, and (reviews) state.
wf="$root/.github/workflows/qa-gate.yml"
filter=$(python3 - "$wf" <<'PY'
import re, sys
s = open(sys.argv[1]).read()
print(re.search(r"--argjson allow \"\$allow_json\" '(.*?)'\)", s, re.S).group(1))
PY
)
sha=0123456789abcdef0123456789abcdef01234567
old=fedcba9876543210fedcba9876543210fedcba98
T1=2026-10-21T20:00:00Z; T2=2026-10-21T20:05:00Z; T3=2026-10-21T20:10:00Z
L=$'\n'
# item LOGIN CREATED UPDATED BODY [STATE]
item() { jq -cn --arg u "$1" --arg c "$2" --arg m "$3" --arg b "$4" --arg s "${5:-}" \
  '{user:{login:$u},created_at:$c,updated_at:$m,body:$b} + (if $s == "" then {} else {state:$s} end)'; }
v() { # expected description items...
  local want=$1 name=$2; shift 2
  total=$((total + 1))
  local got; got=$(printf '%s\n' "$@" | jq -r -s --arg sha "$sha" --argjson allow '["AgileKnow23"]' "$filter" 2>&1)
  if [ "$got" = "$want" ]; then echo "ok   qa-gate: $name"; else echo "FAIL qa-gate: $name (got '$got', expected '$want')"; fails=$((fails + 1)); fi
}
ship() { item AgileKnow23 "$1" "${2:-$1}" "Independent QA by Principal QA: SHIP${L}Head tested: \`$sha\`"; }

v "" "no comments"
v "" "comment that is not a verdict" "$(item AgileKnow23 $T1 $T1 'looks fine')"
# Principal QA's 21 adversarial cases (QA report 2026-10-21, qa-gate-adversarial.sh)
v SHIP "QA 1: plain SHIP, SHA on line 2" "$(ship $T1)"
v "" "QA 2: SHIP from a non-allowlisted login" "$(item mallory $T1 $T1 "Independent QA by Principal QA: SHIP${L}$sha")"
v SHIP "QA 3: SHIP from any agent on the shared login (known limit, see README)" "$(item AgileKnow23 $T1 $T1 "Independent QA by Principal Engineer: SHIP${L}$sha")"
v "" "QA 4: SHIP naming only an old head" "$(item AgileKnow23 $T1 $T1 "Independent QA by Q: SHIP${L}$old")"
v SHIP "QA 5: SHIP naming an old head but mentioning the current SHA" "$(item AgileKnow23 $T1 $T1 "Independent QA by Q: SHIP${L}Tested $old (head was later $sha)")"
v "" "QA 6: SHIP in a blockquote" "$(item AgileKnow23 $T1 $T1 "> Independent QA by Q: SHIP${L}$sha")"
v "" "QA 7: SHIP in a code block" "$(item AgileKnow23 $T1 $T1 "\`\`\`${L}Independent QA by Q: SHIP${L}\`\`\`${L}$sha")"
v "" "QA 8: SHIP line not first" "$(item AgileKnow23 $T1 $T1 "Re-check below${L}Independent QA by Q: SHIP${L}$sha")"
v "" "QA 9: bold first line" "$(item AgileKnow23 $T1 $T1 "**Independent QA by Q: SHIP**${L}$sha")"
v "" "QA 10: lowercase ship" "$(item AgileKnow23 $T1 $T1 "Independent QA by Q: ship${L}$sha")"
v "" "QA 11: trailing space after SHIP" "$(item AgileKnow23 $T1 $T1 "Independent QA by Q: SHIP ${L}$sha")"
v SHIP-WITH-FIXES "QA 12: SHIP-WITH-FIXES" "$(item AgileKnow23 $T1 $T1 "Independent QA by Q: SHIP-WITH-FIXES${L}$sha")"
v "SHIP WITH FIXES" "QA 13: SHIP WITH FIXES" "$(item AgileKnow23 $T1 $T1 "Independent QA by Q: SHIP WITH FIXES${L}$sha")"
v NO-SHIP "QA 14: NO-SHIP is not read as SHIP" "$(item AgileKnow23 $T1 $T1 "Independent QA by Q: NO-SHIP${L}$sha")"
v NO-SHIP "QA 15: SHIP then a later NO-SHIP" "$(ship $T1)" "$(item AgileKnow23 $T2 $T2 "Independent QA by Q: NO-SHIP${L}$sha")"
v NO-SHIP "QA 16: SHIP then a later malformed 'NO SHIP' (fail closed)" "$(ship $T1)" "$(item AgileKnow23 $T2 $T2 "Independent QA by Q: NO SHIP${L}$sha")"
v NO-SHIP "QA 17: SHIP then a later NO-SHIP with trailing space (fail closed)" "$(ship $T1)" "$(item AgileKnow23 $T2 $T2 "Independent QA by Q: NO-SHIP ${L}$sha")"
v NO-SHIP "QA 18: SHIP then a later NO-SHIP naming only a short SHA (fail closed)" "$(ship $T1)" "$(item AgileKnow23 $T2 $T2 "Independent QA by Q: NO-SHIP${L}${sha:0:7}")"
v NO-SHIP "QA 19: NO-SHIP at T2, older SHIP comment edited at T3" "$(ship $T1 $T3)" "$(item AgileKnow23 $T2 $T2 "Independent QA by Q: NO-SHIP${L}$sha")"
v "" "QA 20: SHIP with prose after the verdict on line 1" "$(item AgileKnow23 $T1 $T1 "Independent QA by Q: SHIP (conditional)${L}$sha")"
v SHIP "QA 21: reviewer name containing ': NO-SHIP'" "$(item AgileKnow23 $T1 $T1 "Independent QA by X: NO-SHIP: SHIP${L}$sha")"
# Further fail-closed and lifecycle cases
v NO-SHIP "SHIP then a later verdict in another spelling ('Ship-With-Fixes')" "$(ship $T1)" "$(item AgileKnow23 $T2 $T2 "Independent QA by Q: Ship-With-Fixes${L}$sha")"
v NO-SHIP "SHIP then a later verdict naming a different full SHA" "$(ship $T1)" "$(item AgileKnow23 $T2 $T2 "Independent QA by Q: SHIP${L}$old")"
v SHIP "non-allowlisted NO-SHIP after SHIP is ignored" "$(ship $T1)" "$(item mallory $T2 $T2 "Independent QA by Q: NO-SHIP${L}$sha")"
v SHIP "SHIP after an earlier NO-SHIP" "$(item AgileKnow23 $T1 $T1 "Independent QA by Q: NO-SHIP${L}$sha")" "$(ship $T2)"
v "" "deleted SHIP comment (no longer returned by the API)" "$(item AgileKnow23 $T1 $T1 'unrelated note')"
v "" "dismissed SHIP review" "$(item AgileKnow23 $T1 $T1 "Independent QA by Q: SHIP${L}$sha" DISMISSED)"
v SHIP "COMMENTED SHIP review" "$(item AgileKnow23 $T1 $T1 "Independent QA by Q: SHIP${L}$sha" COMMENTED)"
v SHIP "CRLF first line" "$(item AgileKnow23 $T1 $T1 "Independent QA by Q: SHIP"$'\r'"${L}$sha")"
# Same-second ties and pending reviews (Principal QA N2): a tie with anything other than a
# valid SHIP blocks, and a review that was never submitted never counts.
pending() { jq -cn --arg b "$1" --arg s "${2:-}" \
  '{user:{login:"AgileKnow23"},created_at:null,updated_at:null,body:$b} + (if $s == "" then {} else {state:$s} end)'; }
v NO-SHIP "malformed verdict in the same second as a SHIP blocks it" "$(ship $T1)" "$(item AgileKnow23 $T1 $T1 "Independent QA by Q: NO SHIP${L}$sha")"
v NO-SHIP "malformed verdict in the same second, listed first, blocks" "$(item AgileKnow23 $T1 $T1 "Independent QA by Q: NO SHIP${L}$sha")" "$(ship $T1)"
v NO-SHIP "NO-SHIP in the same second as a SHIP, listed first, blocks" "$(item AgileKnow23 $T1 $T1 "Independent QA by Q: NO-SHIP${L}$sha")" "$(ship $T1)"
v SHIP "two SHIPs in the same second pass" "$(ship $T1)" "$(ship $T1)"
v "" "pending SHIP review (state PENDING, no submitted_at) never counts" "$(pending "Independent QA by Q: SHIP${L}$sha" PENDING)"
v "" "SHIP review with no submitted_at and no state never counts" "$(pending "Independent QA by Q: SHIP${L}$sha")"
v NO-SHIP "pending SHIP review does not override an earlier NO-SHIP" "$(item AgileKnow23 $T1 $T1 "Independent QA by Q: NO-SHIP${L}$sha")" "$(pending "Independent QA by Q: SHIP${L}$sha" PENDING)"
# Principal QA N3: the blocking test is "first line contains 'Independent QA by' in any case",
# not only lines that start with it.
v NO-SHIP "later first line containing 'independent qa by' mid-line, lowercase, blocks" "$(ship $T1)" "$(item AgileKnow23 $T2 $T2 "Re: independent qa by Q: NO SHIP${L}$sha")"
v NO-SHIP "later first line in upper case blocks" "$(ship $T1)" "$(item AgileKnow23 $T2 $T2 "INDEPENDENT QA BY Q: SHIP${L}$sha")"
v SHIP "later comment that only mentions QA without the phrase does not block" "$(ship $T1)" "$(item AgileKnow23 $T2 $T2 "QA looks done, thanks${L}$sha")"

total=$((total + 1))
if grep -Eq 'types: \[created, edited, deleted\]' "$wf" && grep -Eq 'types: \[submitted, edited, dismissed\]' "$wf"; then
  echo "ok   qa-gate: re-runs on deleted comments and dismissed reviews"
else echo "FAIL qa-gate: deleted or dismissed trigger missing"; fails=$((fails + 1)); fi

# qa-gate release-please auto-pass decision, extracted from the workflow
release=$(python3 - "$wf" <<'PY'
import re, sys
s = open(sys.argv[1]).read()
print(re.search(r"release_ok=\$\(jq -r --arg repo \"\$REPO\" '(.*?)' <<<", s, re.S).group(1))
PY
)
rel() { # expected description head_ref head_repo author
  local want=$1 name=$2
  total=$((total + 1))
  local got; got=$(jq -cn --arg r "$3" --arg hr "$4" --arg a "$5" '{head:{ref:$r,repo:{full_name:$hr}},user:{login:$a}}' \
    | jq -r --arg repo OutcomefocusAi/repo-template "$release" 2>&1)
  if [ "$got" = "$want" ]; then echo "ok   qa-gate release: $name"; else echo "FAIL qa-gate release: $name (got '$got', expected '$want')"; fails=$((fails + 1)); fi
}
rel true "release-please pull request from this repository" release-please--branches--main OutcomefocusAi/repo-template 'github-actions[bot]'
rel false "fork branch named release-please--*" release-please--branches--main mallory/repo-template 'mallory'
rel false "same-repository branch named release-please--* opened by an agent" release-please--x OutcomefocusAi/repo-template AgileKnow23
rel false "ordinary branch" 1-bootstrap-repo-template OutcomefocusAi/repo-template AgileKnow23

# release-please version state (design D6; change fix-first-release-check). The check reads
# a directory's release-please-config.json, .release-please-manifest.json, version.txt and
# CHANGELOG.md and exits 0 when they are consistent.
release_state() { # dir
  local d=$1 cfg initial bump manifest version heading semver='^[0-9]+\.[0-9]+\.[0-9]+$'
  cfg='.packages["."]'
  initial=$(jq -r "$cfg[\"initial-version\"] // \"unset\"" "$d/release-please-config.json")
  bump=$(jq -r "$cfg | if has(\"bump-minor-pre-major\") then .[\"bump-minor-pre-major\"] | tostring else \"unset\" end" "$d/release-please-config.json")
  manifest=$(jq -r '.["."]' "$d/.release-please-manifest.json")
  version=$(tr -d '[:space:]' < "$d/version.txt")
  heading=none # newest "## " heading in CHANGELOG.md: "## X.Y.Z (date)" or "## [X.Y.Z](url) (date)"
  if [ -f "$d/CHANGELOG.md" ]; then
    heading=$(grep -m1 '^## ' "$d/CHANGELOG.md" || true)
    if [ -z "$heading" ]; then heading=none
    elif [[ $heading =~ ^##\ \[?([0-9]+\.[0-9]+\.[0-9]+)[]\ ] ]]; then heading=${BASH_REMATCH[1]}
    else heading="unparsed '$heading'"; fi
  fi
  local found="initial-version $initial, bump-minor-pre-major $bump, manifest $manifest, version.txt $version, newest changelog heading $heading"
  if [ "$initial" != "0.1.0" ]; then echo "initial-version must be 0.1.0 ($found)"; return 1; fi
  if [ "$bump" != "true" ]; then echo "bump-minor-pre-major must be true ($found)"; return 1; fi
  if ! [[ $manifest =~ $semver && $version =~ $semver ]]; then echo "manifest and version.txt must be MAJOR.MINOR.PATCH ($found)"; return 1; fi
  if [ "$manifest" != "$version" ]; then echo "manifest and version.txt disagree ($found)"; return 1; fi
  if [ "$manifest" = "0.0.0" ]; then
    if [ "$heading" != none ]; then echo "no release yet, but CHANGELOG.md has a released version ($found)"; return 1; fi
    echo "before the first release: first release is 0.1.0 ($found)"
  else
    if [ "$heading" != "$manifest" ]; then echo "newest CHANGELOG.md heading does not match the version ($found)"; return 1; fi
    echo "released $manifest: version files agree ($found)"
  fi
}
rp_fixture() { # name manifest version.txt bump-minor-pre-major(true|false|string-true|unset) initial-version(0.1.0|unset) [changelog headings...]
  local d="$scratch/rp-$1" manifest=$2 version=$3 bump=$4 initial=$5; shift 5
  mkdir -p "$d"
  jq -n --arg b "$bump" --arg i "$initial" '{packages: {".": ({"release-type": "simple"}
    + (if $i == "unset" then {} else {"initial-version": $i} end)
    + (if $b == "unset" then {} elif $b == "string-true" then {"bump-minor-pre-major": "true"}
       else {"bump-minor-pre-major": ($b == "true")} end))}}' > "$d/release-please-config.json"
  jq -n --arg m "$manifest" '{".": $m}' > "$d/.release-please-manifest.json"
  printf '%s\n' "$version" > "$d/version.txt"
  if [ $# -gt 0 ]; then { echo "# Changelog"; for h in "$@"; do printf '\n%s\n\n* entry\n' "$h"; done; } > "$d/CHANGELOG.md"; fi
  echo "$d"
}
h010='## 0.1.0 (2026-10-21)'
h020='## [0.2.0](https://github.com/OutcomefocusAi/repo-template/compare/v0.1.0...v0.2.0) (2026-11-02)'
expect 0 "release state: before any release (0.0.0, no changelog)" release_state "$(rp_fixture pre 0.0.0 0.0.0 true 0.1.0)"
expect 0 "release state: first release 0.1.0 (release pull request or merged)" release_state "$(rp_fixture first 0.1.0 0.1.0 true 0.1.0 "$h010")"
expect 0 "release state: later release 0.2.0 with a linked heading" release_state "$(rp_fixture later 0.2.0 0.2.0 true 0.1.0 "$h020" "$h010")"
expect 1 "release state: manifest and version.txt disagree" release_state "$(rp_fixture split 0.1.0 0.0.0 true 0.1.0 "$h010")"
expect 1 "release state: newest changelog heading disagrees" release_state "$(rp_fixture stale 0.2.0 0.2.0 true 0.1.0 "$h010")"
expect 1 "release state: 0.0.0 with an inherited released changelog" release_state "$(rp_fixture inherited 0.0.0 0.0.0 true 0.1.0 "$h010")"
expect 1 "release state: bump-minor-pre-major not set" release_state "$(rp_fixture nobump 0.0.0 0.0.0 unset 0.1.0)"
expect 1 "release state: bump-minor-pre-major is the string \"true\", not the boolean" release_state "$(rp_fixture strbump 0.0.0 0.0.0 string-true 0.1.0)"
expect 1 "release state: initial-version not set" release_state "$(rp_fixture noinit 0.0.0 0.0.0 true unset)"
expect 1 "release state: version is not MAJOR.MINOR.PATCH" release_state "$(rp_fixture badver 0.1 0.1 true 0.1.0 '## 0.1 (2026-10-21)')"
expect 0 "release state: this repository" release_state "$root"

echo "test-template-scripts: $((total - fails))/$total passed"
[ "$fails" -eq 0 ]
