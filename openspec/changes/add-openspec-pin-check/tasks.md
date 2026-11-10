# Tasks

## 1. Preconditions

- [ ] 1.1 Record Woody's approval of this proposal in `proposal.md` (card, selected option or exact words, where and when, covers and not covered) and verify the record is committed before any other task starts.
- [ ] 1.2 Verify `origin/main` still has the nine OpenSpec records in agreement and in the formats listed in design.md (`rg -n 'generatedBy|@fission-ai/openspec' .agents/skills .github/workflows TEMPLATE_SOURCE.md`), and save the output in the change folder's `evidence/`. If any record moved or changed format, stop and report so the proposal can be revised.

## 2. Failing self-tests first

- [ ] 2.1 In `scripts/test-template-scripts.sh`, copy `TEMPLATE_SOURCE.md` and `.agents/skills/openspec-*/` into the scratch repository and add cases for `scripts/check-openspec-pin.sh`: exit 0 for the real tree and for a consistent fixture at another version (all nine set to 1.16.0); exit 1 for one Tool pins row at 1.16.1, one Sources row at 1.16.1, one `generatedBy` at 1.16.0, the CI pin at a third version, the CI pin `^1.17.0`, the Tool pins row deleted, a skill without `generatedBy`, and a second Tool pins row. Run the suite and verify these cases fail because the script does not exist yet; commit as `test(ci): ...` with `(#32)`.

## 3. Script

- [ ] 3.1 Write `scripts/check-openspec-pin.sh` per design.md Decision 2 (header comment with usage, `set -euo pipefail`, repo root, `::error file=,line=::` per finding, exit 1 on findings, success line naming the count and version) and verify `scripts/test-template-scripts.sh` passes in full and `scripts/check-openspec-pin.sh` on the branch prints "9 records agree on 1.17.0".
- [ ] 3.2 Verify the error output on two fixtures by hand (one disagreeing record, one missing row) names the file, line and both versions, and save it in `evidence/`.

## 4. CI wiring and docs

- [ ] 4.1 Add the step "OpenSpec pin agreement" running `scripts/check-openspec-pin.sh` right after "Em-dash check" in the `template-checks` job of `.github/workflows/ci.yml`, and verify `scripts/check-workflows.sh` and `actionlint` pass.
- [ ] 4.2 Add one sentence under the Tool pins table in `TEMPLATE_SOURCE.md` saying CI (`scripts/check-openspec-pin.sh`) fails unless the OpenSpec pin, both OpenSpec rows here and the skills' `generatedBy` stamps name the same version, and verify the check still passes (the sentence must not create a second matching row).

## 5. Full local suite

- [ ] 5.1 Run `openspec validate --all --strict` at 1.17.0, `scripts/test-template-scripts.sh`, `scripts/check-openspec-pin.sh`, `scripts/check-em-dash.sh`, `scripts/check-workflows.sh`, actionlint, gitleaks over the full history, `scripts/check-commits.sh` and `git diff --check` at the head, verify all pass, and save the output in `evidence/`.

## Workflow follow-up

- Open the pull request after 5.1 with `Closes #32`, full-SHA links to the change folder, the Notion Tasks row, "Workflow files changed: yes", the scenario-to-check map, the approval record and CI links; verify `template-checks` shows the new step passing and `project` is green.
- Archive with `openspec archive add-openspec-pin-check` (no `--yes`) as the last commit of the implementation pull request, verify `openspec/specs/continuous-integration/spec.md` holds the modified requirement with both new scenarios, then ask Principal QA for the verdict on that head and verify `qa-gate` is green.
- Merge only on Woody's tap after QA SHIP on the current head with green CI, squash-merged with a subject ending in `(#32)` and `Closes #32`.
