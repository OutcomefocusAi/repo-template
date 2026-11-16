# Tasks

## 1. Preconditions

- [x] 1.1 Record Woody's approval of this proposal in `proposal.md` (card, selected option or exact words, where and when, covers and not covered), and verify the record is committed before any other task starts.
- [x] 1.2 Re-check on the day of apply that the CI pin is still `@fission-ai/openspec@2.0.0` and that npm `latest` is still 2.0.0, and re-run the design's probes (`init --tools agents --profile core` in an empty directory is byte-identical to the committed generated skills; a deleted skill folder is not restored by `update`); save the output in `evidence/`. If the pin or the probe results changed, stop and report.

## 2. Failing self-tests first

- [x] 2.1 Add to `scripts/test-template-scripts.sh` a stub `openspec` (version from an environment variable; `init` copies the template's committed generated skill files into its working directory and writes a marker file) and these cases for `scripts/check-openspec-skills.sh`: clean tree passes; edited skill text, edited `generatedBy` stamp, deleted `SKILL.md`, deleted skill folder, extra tracked file, untracked new `openspec-*` folder, stub at a different version than the CI pin, CI pin a range, CI pin line missing and no `openspec` command each fail; each failing case also checks the annotation names the expected file. Add one case asserting `git status --porcelain --untracked-files=all` is unchanged and no marker file exists in the checkout after a passing and a failing run. Verify the new cases fail (script missing) while every existing case still passes, commit, and save the output in `evidence/`.

## 3. Script

- [x] 3.1 Write `scripts/check-openspec-skills.sh` per design.md (pin from `ci.yml`, CLI version check, reference from `init --tools agents --profile core` in a temporary directory with a temporary `XDG_CONFIG_HOME`, `cmp` comparison, one `::error file=<path>,line=1::` per drifted file with the fix, success line with count and version). Verify every self-test passes and shellcheck is clean on the new script.
- [x] 3.2 Run the script on the real tree with the real OpenSpec 2.0.0 CLI (`OPENSPEC_CMD="npx -y @fission-ai/openspec@2.0.0"`, npm cache in `/tmp`): verify it passes, then on a scratch copy verify an edited skill, a deleted folder and an untracked extra file each produce the expected annotations and fix text, and that `git status` is unchanged by each run. Save the output in `evidence/`.

## 4. CI step and docs

- [ ] 4.1 Add the step "OpenSpec skills match generation" (`run: scripts/check-openspec-skills.sh`) to `template-checks` in `.github/workflows/ci.yml` right after "OpenSpec pin agreement", and verify `scripts/check-workflows.sh` and actionlint pass.
- [ ] 4.2 Add one sentence to `TEMPLATE_SOURCE.md` under the Tool pins table naming `scripts/check-openspec-skills.sh`, what it compares and the fix command, and verify `scripts/check-em-dash.sh` passes.

## 5. Checks and archive

- [ ] 5.1 Run `openspec validate --all --strict` at 2.0.0, `scripts/test-template-scripts.sh`, `scripts/check-em-dash.sh`, `scripts/check-openspec-pin.sh`, `scripts/check-openspec-skills.sh`, `scripts/check-ponytail-pin.sh`, `scripts/check-workflows.sh`, actionlint, gitleaks over the full history, `scripts/check-commits.sh` and `git diff --check` at the head, verify all pass, and save the output in `evidence/`.
- [ ] 5.2 After 5.1 and after the pull request (follow-up below) is open with green CI, archive the change with `openspec archive add-openspec-skill-drift-check` at 2.0.0 (no `--yes`) as the last commit of the implementation pull request, before Principal QA reviews, and verify `openspec/specs/continuous-integration/spec.md` holds the modified requirement with the six new scenarios.

## Workflow follow-up

- Open the pull request before 5.2 with `Closes #37`, full-SHA links to the change folder, the Notion Tasks row, "Workflow files changed: yes", the scenario-to-test map, the approval record and CI links, and verify `template-checks` (log shows the new step and its success line) and `project` are green.
- After the archive commit, ask Principal QA for the verdict (COMMENT review, first line `Independent QA by <reviewer>: ...`) on that head and verify `qa-gate` is green. If QA fix commits land after the archive commit, add them to the same branch, update the archived folder and merged spec in a further commit if the fixes change what they describe, and ask QA to re-review the new head.
- Merge only on Woody's tap (this adds CI behavior; not version-only), after QA `SHIP` on the current head with green CI, squash-merged with a subject ending in `(#37)` and `Closes #37`.
