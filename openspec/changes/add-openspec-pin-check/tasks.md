# Tasks

## 1. Preconditions

- [x] 1.1 Record Woody's approval of this proposal, including the Ponytail scope extension, in `proposal.md` (card, selected option, where and when, covers and not covered) and verify the record is committed before any other task starts.
- [x] 1.2 Verify the branch base still has the nine OpenSpec records and the Ponytail records (three `SOURCE.md` files plus the `TEMPLATE_SOURCE.md` row) in agreement and in the formats listed in design.md (`rg -n 'generatedBy|@fission-ai/openspec' .agents/skills .github/workflows TEMPLATE_SOURCE.md`, `rg -n 'Pinned commit|Upstream version|File at that commit|SHA-256' .agents/skills/ponytail*/SOURCE.md`, `sha256sum .agents/skills/ponytail*/{SKILL.md,LICENSE}`), and save the output in the change folder's `evidence/`. If any record moved or changed format, stop and report so the proposal can be revised.

## 2. Failing self-tests first

- [x] 2.1 In `scripts/test-template-scripts.sh`, copy `TEMPLATE_SOURCE.md` and `.agents/skills/` into the scratch repository and add cases for `scripts/check-openspec-pin.sh`: exit 0 for the real tree and for a consistent fixture at another version (all nine set to 1.16.0); exit 1 for one Tool pins row at 1.16.1, one Sources row at 1.16.1, one `generatedBy` at 1.16.0, the CI pin at a third version, the CI pin `^1.17.0`, the Tool pins row deleted, a skill without `generatedBy`, and a second Tool pins row.
- [x] 2.2 In the same file, add cases for `scripts/check-ponytail-pin.sh`: exit 0 for the real tree and for a consistent fixture at another commit (all four commit records, the three links and all four describe strings changed together); exit 1 for one `SOURCE.md` "Pinned commit" changed, the `TEMPLATE_SOURCE.md` row commit changed, one "File at that commit" link SHA changed, one describe string changed, a short SHA in all four records, an edited vendored `SKILL.md`, a wrong recorded `LICENSE` SHA-256, a missing `SOURCE.md`, and the `TEMPLATE_SOURCE.md` Ponytail row deleted. Run the suite and verify the cases from 2.1 and 2.2 fail because neither script exists yet; commit as `test(ci): ...` with `(#32)`.

## 3. Scripts

- [x] 3.1 Write `scripts/check-openspec-pin.sh` per design.md Decision 2 (header comment with usage, `set -euo pipefail`, repo root, `::error file=,line=::` per finding, exit 1 on findings, success line naming the count and version) and verify its self-test cases pass and the script on the branch prints "9 records agree on 1.17.0".
- [ ] 3.2 Write `scripts/check-ponytail-pin.sh` per design.md Decision 4 (same conventions) and verify `scripts/test-template-scripts.sh` passes in full and the script on the branch prints "3 skill(s) agree on 96608e078b2d5ea607c5c3b8b5a54d1c1fba6846 (v5.3.3-1-g96608e0)".
- [ ] 3.3 Verify by hand that the error output on mismatch fixtures for both scripts (a disagreeing record, a missing row, and for Ponytail an edited `SKILL.md`) names the file, line and both values, and save it in `evidence/`.

## 4. CI wiring and docs

- [ ] 4.1 Add the steps "OpenSpec pin agreement" (`scripts/check-openspec-pin.sh`) and "Ponytail pin agreement" (`scripts/check-ponytail-pin.sh`) right after "Em-dash check" in the `template-checks` job of `.github/workflows/ci.yml`, and verify `scripts/check-workflows.sh` and `actionlint` pass.
- [ ] 4.2 Add one or two sentences under the Tool pins table in `TEMPLATE_SOURCE.md` saying CI fails unless the OpenSpec records agree (`scripts/check-openspec-pin.sh`) and unless the Ponytail records agree and match the vendored files (`scripts/check-ponytail-pin.sh`), and verify both checks still pass (the sentences must not create a second matching row).

## 5. Full local suite

- [ ] 5.1 Reinstall CI tools with `scripts/install-ci-tools.sh /tmp/citools`, then run `openspec validate --all --strict` at 1.17.0, `scripts/test-template-scripts.sh`, both new checks, `scripts/check-em-dash.sh`, `scripts/check-workflows.sh`, actionlint, shellcheck on the new scripts (informational, CI does not run it), gitleaks over the full history after `git fetch`, `scripts/check-commits.sh` and `git diff --check` at the head; verify all pass and save the output in `evidence/`.

## Workflow follow-up

- Open the pull request after 5.1 with `Closes #32`, full-SHA links to the change folder, the Notion Tasks row, "Workflow files changed: yes", the scenario-to-check map, the approval records and CI links; verify `template-checks` shows both new steps passing and `project` is green.
- Archive with `openspec archive add-openspec-pin-check` (no `--yes`) as the last commit of the implementation pull request, verify `openspec/specs/continuous-integration/spec.md` holds the modified requirement with all four new scenarios, then ask Principal QA for the verdict on that head and verify `qa-gate` is green.
- Merge only on Woody's tap after QA SHIP on the current head with green CI, squash-merged with a subject ending in `(#32)` and `Closes #32`.
