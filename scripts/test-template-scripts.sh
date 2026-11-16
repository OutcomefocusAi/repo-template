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

# check-openspec-pin and check-ponytail-pin: the real records pass, then one drift at a time.
# Each fixture edits the committed copies in the scratch repository and is undone after its case.
mkdir -p "$repo/.agents"; cp -R "$root/.agents/skills" "$repo/.agents/"; cp "$root/TEMPLATE_SOURCE.md" "$repo/"
git -C "$repo" add .agents TEMPLATE_SOURCE.md .github/workflows; git -C "$repo" commit -q -m "chore: pin records (#1)"
pin() { # expected-exit description script fixture-function
  in_repo "$4"
  if git -C "$repo" diff --quiet -- .agents TEMPLATE_SOURCE.md .github/workflows; then
    total=$((total + 1)); fails=$((fails + 1)); echo "FAIL $2 (fixture $4 changed nothing)"
  else
    expect "$1" "$2" in_repo "scripts/$3"
  fi
  git -C "$repo" checkout -q -- .agents TEMPLATE_SOURCE.md .github/workflows
}
V='[0-9]+\.[0-9]+\.[0-9]+'
os_all_other()   { sed -Ei "s/(generatedBy: \")$V/\10.0.1/" .agents/skills/openspec-*/SKILL.md; sed -Ei "s/(@fission-ai\/openspec@)$V/\10.0.1/" .github/workflows/ci.yml
                   sed -Ei "s/(\`@fission-ai\/openspec\` )$V/\10.0.1/; s/^(\| @fission-ai\/openspec \| )$V/\10.0.1/" TEMPLATE_SOURCE.md; }
os_toolpins()    { sed -Ei "s/^(\| @fission-ai\/openspec \| )$V/\10.0.1/" TEMPLATE_SOURCE.md; }
os_sources()     { sed -Ei "s/(\`@fission-ai\/openspec\` )$V/\10.0.1/" TEMPLATE_SOURCE.md; }
os_stamp()       { sed -Ei "s/(generatedBy: \")$V/\10.0.1/" .agents/skills/openspec-propose/SKILL.md; }
os_ci_third()    { os_toolpins; sed -Ei "s/(@fission-ai\/openspec@)$V/\10.0.2/" .github/workflows/ci.yml; }
os_ci_range()    { sed -Ei "s/(@fission-ai\/openspec@)/\1^/" .github/workflows/ci.yml; }
os_no_row()      { sed -Ei '/^\| @fission-ai\/openspec \|/d' TEMPLATE_SOURCE.md; }
os_no_stamp()    { sed -Ei '/generatedBy:/d' .agents/skills/openspec-explore/SKILL.md; }
os_two_rows()    { sed -Ei '/^\| @fission-ai\/openspec \|/p' TEMPLATE_SOURCE.md; }
expect 0 "check-openspec-pin: template records agree" in_repo scripts/check-openspec-pin.sh
pin 0 "check-openspec-pin: all nine records at another version" check-openspec-pin.sh os_all_other
pin 1 "check-openspec-pin: Tool pins row disagrees" check-openspec-pin.sh os_toolpins
pin 1 "check-openspec-pin: Sources row disagrees" check-openspec-pin.sh os_sources
pin 1 "check-openspec-pin: one generatedBy disagrees" check-openspec-pin.sh os_stamp
pin 1 "check-openspec-pin: CI pin at a third version" check-openspec-pin.sh os_ci_third
pin 1 "check-openspec-pin: CI pin is a range" check-openspec-pin.sh os_ci_range
pin 1 "check-openspec-pin: Tool pins row missing" check-openspec-pin.sh os_no_row
pin 1 "check-openspec-pin: skill without generatedBy" check-openspec-pin.sh os_no_stamp
pin 1 "check-openspec-pin: Tool pins row twice" check-openspec-pin.sh os_two_rows

PROW='^\| `\.agents\/skills\/ponytail\/`'
alt=0123456789abcdef0123456789abcdef01234567
pt_all_other()   { sed -Ei "s/\b[0-9a-f]{40}\b/$alt/g; s/\`v[^\`]*\`/\`v0.0.1\`/" .agents/skills/ponytail*/SOURCE.md
                   sed -Ei "/$PROW/{s/\b[0-9a-f]{40}\b/$alt/; s/\`v[^\`]*\`/\`v0.0.1\`/}" TEMPLATE_SOURCE.md; }
pt_commit()      { sed -Ei "/^\| Pinned commit \|/s/[0-9a-f]{40}/$alt/" .agents/skills/ponytail-review/SOURCE.md; }
pt_row_commit()  { sed -Ei "/$PROW/s/\b[0-9a-f]{40}\b/$alt/" TEMPLATE_SOURCE.md; }
pt_link()        { sed -Ei "/^\| File at that commit \|/s/[0-9a-f]{40}/$alt/" .agents/skills/ponytail-audit/SOURCE.md; }
pt_describe()    { sed -Ei "/^\| Upstream version \|/s/\`v[^\`]*\`/\`v0.0.1\`/" .agents/skills/ponytail-audit/SOURCE.md; }
pt_short()       { sed -Ei 's/\b([0-9a-f]{7})[0-9a-f]{33}\b/\1/g' .agents/skills/ponytail*/SOURCE.md; sed -Ei "/$PROW/s/\b([0-9a-f]{7})[0-9a-f]{33}\b/\1/" TEMPLATE_SOURCE.md; }
pt_edit_skill()  { echo "local edit" >> .agents/skills/ponytail/SKILL.md; }
pt_license_hash(){ sed -Ei "/^\| SHA-256 of \`LICENSE\` \|/s/[0-9a-f]{64}/$(printf '0%.0s' {1..64})/" .agents/skills/ponytail/SOURCE.md; }
pt_no_source()   { rm .agents/skills/ponytail-review/SOURCE.md; }
pt_no_row()      { sed -Ei "/$PROW/d" TEMPLATE_SOURCE.md; }
expect 0 "check-ponytail-pin: template records agree" in_repo scripts/check-ponytail-pin.sh
pin 0 "check-ponytail-pin: all records at another commit" check-ponytail-pin.sh pt_all_other
pin 1 "check-ponytail-pin: one SOURCE.md commit disagrees" check-ponytail-pin.sh pt_commit
pin 1 "check-ponytail-pin: TEMPLATE_SOURCE.md row commit disagrees" check-ponytail-pin.sh pt_row_commit
pin 1 "check-ponytail-pin: link SHA disagrees" check-ponytail-pin.sh pt_link
pin 1 "check-ponytail-pin: describe string disagrees" check-ponytail-pin.sh pt_describe
pin 1 "check-ponytail-pin: short SHA everywhere" check-ponytail-pin.sh pt_short
pin 1 "check-ponytail-pin: edited vendored SKILL.md" check-ponytail-pin.sh pt_edit_skill
pin 1 "check-ponytail-pin: wrong recorded LICENSE SHA-256" check-ponytail-pin.sh pt_license_hash
pin 1 "check-ponytail-pin: SOURCE.md missing" check-ponytail-pin.sh pt_no_source
pin 1 "check-ponytail-pin: TEMPLATE_SOURCE.md Ponytail row missing" check-ponytail-pin.sh pt_no_row

# check-openspec-skills: the generated OpenSpec skill files must equal what the pinned version
# generates. A stub openspec on PATH stands in for the CLI so these cases need no network: its
# init copies the template's committed generated files (the reference) into its working
# directory, drops a marker file there and logs where and how it ran, and the XDG_CONFIG_HOME and
# XDG_DATA_HOME it saw. STUB_INIT_MODE=fail makes init exit 3; STUB_INIT_MODE=empty writes nothing.
stub="$scratch/stub"; ref="$scratch/skills-ref"; mkdir -p "$stub" "$ref/.agents/skills"
cp "$root/.agents/skills/.openspec-target" "$ref/.agents/skills/"; cp -R "$root"/.agents/skills/openspec-* "$ref/.agents/skills/"
cat > "$stub/openspec" <<'STUB'
#!/usr/bin/env bash
case "${1:-}" in
  --version) echo "${STUB_OPENSPEC_VERSION:?}" ;;
  init) printf '%s %s\n' "$PWD" "$*" >> "${STUB_LOG:?}"; touch .stub-init-ran
        printf 'xdg %s %s\n' "${XDG_CONFIG_HOME:-}" "${XDG_DATA_HOME:-}" >> "$STUB_LOG"
        case "${STUB_INIT_MODE:-}" in
          fail) echo "stub init failed on purpose" >&2; exit 3 ;;
          empty) exit 0 ;;
        esac
        mkdir -p .agents/skills; cp -R "${STUB_REF:?}/.agents/skills/." .agents/skills/ ;;
  *) echo "stub openspec: unsupported: $*" >&2; exit 2 ;;
esac
STUB
chmod +x "$stub/openspec"
pinv=$(sed -nE 's/.*@fission-ai\/openspec@([0-9]+\.[0-9]+\.[0-9]+).*/\1/p' "$root/.github/workflows/ci.yml" | head -n1)
SKENV=()
skills() { # expected-exit description fixture-function expected-text...
  local want=$1 name=$2 fixture=$3; shift 3
  local before after got why=""
  before=$(git -C "$repo" status --porcelain --untracked-files=all)
  [ "$fixture" = none ] || in_repo "$fixture"
  after=$(git -C "$repo" status --porcelain --untracked-files=all)
  if [ "$fixture" != none ] && [ "$before" = "$after" ]; then why="fixture $fixture changed nothing"; fi
  : > "$scratch/stub.log"
  (cd "$repo" && env PATH="$stub:$PATH" STUB_OPENSPEC_VERSION="$pinv" STUB_REF="$ref" STUB_LOG="$scratch/stub.log" \
    "${SKENV[@]}" scripts/check-openspec-skills.sh) >"$scratch/out" 2>&1; got=$?
  [ -n "$why" ] || [ "$got" -eq "$want" ] || why="exit $got, expected $want"
  for t in "$@"; do [ -n "$why" ] || grep -qF -- "$t" "$scratch/out" || why="output lacks: $t"; done
  [ -n "$why" ] || [ "$after" = "$(git -C "$repo" status --porcelain --untracked-files=all)" ] || why="the check changed the checkout"
  [ -n "$why" ] || [ ! -e "$repo/.stub-init-ran" ] || why="generation ran inside the checkout"
  total=$((total + 1))
  if [ -z "$why" ]; then echo "ok   $name"; else
    echo "FAIL $name ($why)"; sed 's/^/     /' "$scratch/out"; fails=$((fails + 1)); fi
  # A fixture may replace .agents or .agents/skills with a link; drop the links and copies first.
  for l in "$repo/.agents/skills" "$repo/.agents"; do [ ! -L "$l" ] || rm "$l"; done
  rm -rf "$repo/.agents/skills-real" "$repo/.agents-real"
  git -C "$repo" reset -q -- .agents .agents-real .github/workflows; git -C "$repo" checkout -q -- .agents .github/workflows
  git -C "$repo" clean -fdq -- .agents; rm -f "$repo/.stub-init-ran"; SKENV=()
}
sk_edit()      { echo "local edit" >> .agents/skills/openspec-apply-change/SKILL.md; }
sk_stamp()     { sed -Ei 's/(generatedBy: ")[0-9.]+/\10.0.1/' .agents/skills/openspec-propose/SKILL.md; }
sk_rm_file()   { rm .agents/skills/openspec-sync-specs/SKILL.md; }
sk_rm_dir()    { rm -r .agents/skills/openspec-explore; }
sk_rm_target() { rm .agents/skills/.openspec-target; }
sk_extra()     { echo "notes" > .agents/skills/openspec-propose/notes.md; git add .agents/skills/openspec-propose/notes.md; }
sk_untracked() { mkdir .agents/skills/openspec-extra; echo "mine" > .agents/skills/openspec-extra/SKILL.md; }
sk_pin_range() { sed -Ei 's/(@fission-ai\/openspec@)/\1^/' .github/workflows/ci.yml; }
sk_pin_gone()  { sed -Ei '/@fission-ai\/openspec@/d' .github/workflows/ci.yml; }
fix="npx -y @fission-ai/openspec@$pinv"
skills 0 "check-openspec-skills: generated skills match" none "check-openspec-skills: 7 generated file(s) match OpenSpec $pinv"
total=$((total + 1))
if grep -q -- " init --tools agents --profile core$" "$scratch/stub.log" && ! grep -qF -e "$repo/" -e "$repo " "$scratch/stub.log"; then
  echo "ok   check-openspec-skills: reference from init --tools agents --profile core outside the checkout"
else echo "FAIL check-openspec-skills: reference from init --tools agents --profile core outside the checkout"; sed 's/^/     /' "$scratch/stub.log"; fails=$((fails + 1)); fi
skills 1 "check-openspec-skills: edited skill text" sk_edit "::error file=.agents/skills/openspec-apply-change/SKILL.md,line=1::edited" "$fix update"
skills 1 "check-openspec-skills: edited generatedBy stamp" sk_stamp "::error file=.agents/skills/openspec-propose/SKILL.md,line=1::edited"
skills 1 "check-openspec-skills: deleted SKILL.md" sk_rm_file "::error file=.agents/skills/openspec-sync-specs/SKILL.md,line=1::missing" "$fix init --tools agents --profile core"
skills 1 "check-openspec-skills: deleted skill folder" sk_rm_dir "::error file=.agents/skills/openspec-explore/SKILL.md,line=1::missing"
skills 1 "check-openspec-skills: deleted .openspec-target" sk_rm_target "::error file=.agents/skills/.openspec-target,line=1::missing"
skills 1 "check-openspec-skills: extra tracked file in a skill folder" sk_extra "::error file=.agents/skills/openspec-propose/notes.md,line=1::extra"
skills 1 "check-openspec-skills: untracked new openspec-* folder" sk_untracked "::error file=.agents/skills/openspec-extra/SKILL.md,line=1::untracked"
SKENV=(STUB_OPENSPEC_VERSION=0.0.1)
skills 1 "check-openspec-skills: CLI at another version than the CI pin" none "::error file=.github/workflows/ci.yml" "0.0.1" "$pinv"
skills 1 "check-openspec-skills: CI pin is a range" sk_pin_range "::error file=.github/workflows/ci.yml"
skills 1 "check-openspec-skills: CI pin line missing" sk_pin_gone "::error file=.github/workflows/ci.yml"
SKENV=(OPENSPEC_CMD=no-such-openspec-command)
skills 1 "check-openspec-skills: no OpenSpec CLI" none "::error file=.github/workflows/ci.yml" "no-such-openspec-command"
# File mode and type (#39 D1): init writes regular 100644 files, so an exec bit or a symlink is drift.
sk_exec()      { chmod +x .agents/skills/openspec-propose/SKILL.md; git add .agents/skills/openspec-propose/SKILL.md; }
sk_link()      { cp .agents/skills/openspec-propose/SKILL.md .agents/skills/copy-of-propose.md
                 ln -sf ../copy-of-propose.md .agents/skills/openspec-propose/SKILL.md; git add -A .agents; }
sk_link_untr() { git rm -q --cached .agents/skills/openspec-explore/SKILL.md; cp .agents/skills/openspec-explore/SKILL.md .agents/skills/copy-of-explore.md
                 ln -sf ../copy-of-explore.md .agents/skills/openspec-explore/SKILL.md; }
skills 1 "check-openspec-skills: exec bit in the index, mode 100755" sk_exec "::error file=.agents/skills/openspec-propose/SKILL.md,line=1::mode: git mode 100755" "100644" "git update-index --chmod=-x"
sk_exec_idx()  { git update-index --chmod=+x .agents/skills/openspec-sync-specs/SKILL.md; }
skills 1 "check-openspec-skills: exec bit only in the index, as a Windows commit would set it" sk_exec_idx "::error file=.agents/skills/openspec-sync-specs/SKILL.md,line=1::mode: git mode 100755"
skills 1 "check-openspec-skills: SKILL.md as a symlink to an identical copy" sk_link "::error file=.agents/skills/openspec-propose/SKILL.md,line=1::symlink:"
skills 1 "check-openspec-skills: untracked symlink at a generated path" sk_link_untr "::error file=.agents/skills/openspec-explore/SKILL.md,line=1::symlink:"
# Linked parent directories (#41 E1): init writes real directories.
sk_skills_link() { mv .agents/skills .agents/skills-real; ln -s skills-real .agents/skills; git add -A .agents; }
sk_agents_link() { mv .agents .agents-real; ln -s .agents-real .agents; git add -A .agents .agents-real; }
skills 1 "check-openspec-skills: .agents/skills committed as a symlink to an identical copy" sk_skills_link "::error file=.agents/skills,line=1::symlink:" "real directory"
skills 1 "check-openspec-skills: .agents committed as a symlink to an identical copy" sk_agents_link "::error file=.agents,line=1::symlink:" "real directory"
# Cases that kill the PR #40 QA survivors (#41 E2): an on-disk link beats the index mode, and an
# untracked executable file gets mode: with the chmod and git add fix.
sk_link_over() { cp .agents/skills/openspec-archive-change/SKILL.md .agents/skills/copy-of-archive.md; rm .agents/skills/openspec-archive-change/SKILL.md
                 ln -s ../copy-of-archive.md .agents/skills/openspec-archive-change/SKILL.md; }
sk_exec_untr() { git rm -q --cached .agents/skills/openspec-update-change/SKILL.md; chmod +x .agents/skills/openspec-update-change/SKILL.md; }
skills 1 "check-openspec-skills: uncommitted symlink over a tracked SKILL.md" sk_link_over "::error file=.agents/skills/openspec-archive-change/SKILL.md,line=1::symlink:"
skills 1 "check-openspec-skills: untracked executable generated file" sk_exec_untr "::error file=.agents/skills/openspec-update-change/SKILL.md,line=1::mode: git mode 100755 but OpenSpec $pinv generates 100644" "run 'chmod -x .agents/skills/openspec-update-change/SKILL.md' and commit it with 'git add -- .agents/skills/openspec-update-change/SKILL.md'"
# Cases that pin behavior the PR #38 QA mutants could break unnoticed (#39 D2).
sk_untr_match() { git rm -q --cached .agents/skills/.openspec-target; }
sk_pin_two()    { sed -Ei 's/^( *)(npm install .*@fission-ai\/openspec@.*)$/\1\2\n\1# also @fission-ai\/openspec@0.0.1/' .github/workflows/ci.yml; }
sk_pin_rc()     { sed -Ei 's/(@fission-ai\/openspec@)[0-9.]+/\12.0.0-rc.1/' .github/workflows/ci.yml; }
sk_dir_link()   { cp -R .agents/skills/openspec-propose .agents/skills/propose-copy; rm -r .agents/skills/openspec-propose
                  ln -s propose-copy .agents/skills/openspec-propose; git add -A .agents; }
skills 1 "check-openspec-skills: generated file matches but is not committed" sk_untr_match "::error file=.agents/skills/.openspec-target,line=1::untracked: matches" "git add -- .agents/skills/.openspec-target"
skills 1 "check-openspec-skills: two CI pins disagree" sk_pin_two "::error file=.github/workflows/ci.yml" "disagrees"
SKENV=(STUB_OPENSPEC_VERSION=2.0.0-rc.1)
skills 1 "check-openspec-skills: inexact pin even when the CLI reports it" sk_pin_rc "::error file=.github/workflows/ci.yml" "not an exact MAJOR.MINOR.PATCH"
skills 1 "check-openspec-skills: openspec-* folder replaced by a symlink" sk_dir_link "::error file=.agents/skills/openspec-propose/SKILL.md,line=1::missing" "::error file=.agents/skills/openspec-propose,line=1::extra"
SKENV=(STUB_INIT_MODE=fail)
skills 1 "check-openspec-skills: init fails" none "::error file=.github/workflows/ci.yml" "init --tools agents --profile core' failed" "stub init failed on purpose"
SKENV=(STUB_INIT_MODE=empty)
skills 1 "check-openspec-skills: init writes nothing" none "::error file=.github/workflows/ci.yml" "generated no skill files"
# A dedicated TMPDIR must be empty after a passing and a failing run, and the stub must see
# temporary XDG directories inside it, never the caller's.
sktmp="$scratch/sk-tmp"; skuser="$scratch/sk-user"; mkdir -p "$sktmp" "$skuser/config" "$skuser/data"
sk_tmp_check() { # description
  local why=""
  [ -z "$(ls -A "$sktmp")" ] || why="left in TMPDIR: $(ls -A "$sktmp" | tr '\n' ' ')"
  [ -n "$why" ] || [ -z "$(find "$skuser" -mindepth 2 -print -quit)" ] || why="wrote the caller's XDG directories"
  [ -n "$why" ] || grep -qE "^xdg $sktmp/[^ ]+ $sktmp/[^ ]+\$" "$scratch/stub.log" || why="stub did not see temporary XDG directories: $(grep '^xdg' "$scratch/stub.log")"
  total=$((total + 1))
  if [ -z "$why" ]; then echo "ok   $1"; else echo "FAIL $1 ($why)"; fails=$((fails + 1)); fi
}
SKENV=(TMPDIR="$sktmp" XDG_CONFIG_HOME="$skuser/config" XDG_DATA_HOME="$skuser/data")
skills 0 "check-openspec-skills: passes with a caller XDG and a dedicated TMPDIR" none "match OpenSpec $pinv"
sk_tmp_check "check-openspec-skills: temporary dir removed and caller XDG unused after a passing run"
SKENV=(TMPDIR="$sktmp" XDG_CONFIG_HOME="$skuser/config" XDG_DATA_HOME="$skuser/data")
skills 1 "check-openspec-skills: fails with a caller XDG and a dedicated TMPDIR" sk_edit "::error file=.agents/skills/openspec-apply-change/SKILL.md,line=1::edited"
sk_tmp_check "check-openspec-skills: temporary dir removed and caller XDG unused after a failing run"

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
  local d=$1 initial bump component manifest version heading semver='^[0-9]+\.[0-9]+\.[0-9]+$'
  initial=$(jq -r '.packages["."]["initial-version"] // "unset"' "$d/release-please-config.json")
  # release-please honours only the JSON boolean true here, so a string "true" is reported as itself.
  bump=$(jq -r '.packages["."] | if has("bump-minor-pre-major") then .["bump-minor-pre-major"]
    | (if . == true then "true" else tojson end) else "unset" end' "$d/release-please-config.json")
  # Tags and release names are v<semver> only when this is the JSON boolean false (release-please
  # defaults it to true and puts the package name in the tag); anything else is reported as itself.
  component=$(jq -r '.packages["."] | if has("include-component-in-tag") then .["include-component-in-tag"]
    | (if . == false then "false" else tojson end) else "unset" end' "$d/release-please-config.json")
  manifest=$(jq -r '.["."]' "$d/.release-please-manifest.json")
  version=$(tr -d '[:space:]' < "$d/version.txt")
  heading=none # newest "## " heading in CHANGELOG.md: "## X.Y.Z (date)" or "## [X.Y.Z](url) (date)"
  if [ -f "$d/CHANGELOG.md" ]; then
    heading=$(grep -m1 '^## ' "$d/CHANGELOG.md" || true)
    if [ -z "$heading" ]; then heading=none
    elif [[ $heading =~ ^##\ \[?([0-9]+\.[0-9]+\.[0-9]+)[]\ ] ]]; then heading=${BASH_REMATCH[1]}
    else heading="unparsed '$heading'"; fi
  fi
  local found="initial-version $initial, bump-minor-pre-major $bump, include-component-in-tag $component, manifest $manifest, version.txt $version, newest changelog heading $heading"
  if [ "$initial" != "0.1.0" ]; then echo "initial-version must be 0.1.0 ($found)"; return 1; fi
  if [ "$bump" != "true" ]; then echo "bump-minor-pre-major must be the JSON boolean true ($found)"; return 1; fi
  if [ "$component" != "false" ]; then echo "include-component-in-tag must be the JSON boolean false ($found)"; return 1; fi
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
  # include-component-in-tag comes from RP_TAG (false|true|string-false|absent), default false.
  local d="$scratch/rp-$1" manifest=$2 version=$3 bump=$4 initial=$5 tag=${RP_TAG:-false}; shift 5
  mkdir -p "$d"
  jq -n --arg b "$bump" --arg i "$initial" --arg t "$tag" '{packages: {".": ({"release-type": "simple"}
    + (if $i == "unset" then {} else {"initial-version": $i} end)
    + (if $b == "unset" then {} elif $b == "string-true" then {"bump-minor-pre-major": "true"}
       else {"bump-minor-pre-major": ($b == "true")} end)
    + (if $t == "absent" then {} elif $t == "string-false" then {"include-component-in-tag": "false"}
       else {"include-component-in-tag": ($t == "true")} end))}}' > "$d/release-please-config.json"
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
expect 1 "release state: include-component-in-tag not set (tag would be repo-template-v0.1.0)" release_state "$(RP_TAG=absent rp_fixture notag 0.0.0 0.0.0 true 0.1.0)"
expect 1 "release state: include-component-in-tag true" release_state "$(RP_TAG=true rp_fixture tagtrue 0.0.0 0.0.0 true 0.1.0)"
expect 1 "release state: include-component-in-tag is the string \"false\", not the boolean" release_state "$(RP_TAG=string-false rp_fixture strtag 0.0.0 0.0.0 true 0.1.0)"
expect 1 "release state: initial-version not set" release_state "$(rp_fixture noinit 0.0.0 0.0.0 true unset)"
expect 1 "release state: version is not MAJOR.MINOR.PATCH" release_state "$(rp_fixture badver 0.1 0.1 true 0.1.0 '## 0.1 (2026-10-21)')"
expect 0 "release state: this repository" release_state "$root"

echo "test-template-scripts: $((total - fails))/$total passed"
[ "$fails" -eq 0 ]
