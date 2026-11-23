# Tasks

## 1. Preconditions

- [x] 1.1 Verify Woody's approval records (proposal drafting card, and his typed approval of the proposal, apply, fixes and merge) are in `proposal.md` with where and when, and that the commit holding them is on the branch before any other task starts.
- [x] 1.2 Re-check upstream on the day of apply: `npm view @fission-ai/openspec dist-tags.latest` is still 2.1.1, `git ls-remote https://github.com/DietrichGebert/ponytail HEAD` is still `ebd8654c2c627f721eb8f9c0d1bd4090a29f9e10`, and the CI install with `--before=2026-11-21T00:00:00Z` into an empty prefix prints `openspec --version` 2.1.1; save the output in `evidence/`. If anything moved, stop and report.

## 2. Pin check: install cutoff and stamp-free skills

- [ ] 2.1 In `scripts/test-template-scripts.sh`, port the-ordinary-things `22a924a` pin-check cases (the `pin()` text assertions and the 19 cutoff cases) and add cases for: Tool pins row annotations with their line (the-ordinary-things#27), a lowercase `npm_config_` env (#27), `npmrc` and `npm config set` lines, a `\` continuation before the install, a folded `run: >` block, an install in a `.yaml` workflow without a cutoff (#26), all skills without a stamp (passes), stamps on only some skills, two stamps in one skill, and all skills stamped with another version. Run the suite against the unchanged script, verify the new cases fail, save the output and counts in `evidence/2.1-failing-self-tests.txt`, and commit as `test(ci): ... (#47)`.
- [ ] 2.2 Implement design.md decisions 4 and 6 to 8 in `scripts/check-openspec-pin.sh`, add `--before=2026-11-21T00:00:00Z` to the CI install line and record it in the `TEMPLATE_SOURCE.md` Tool pins row with the bump sentence, and verify every self-test passes and `check-openspec-pin.sh` passes on the repository.

## 3. Generated-skills check at 2.1.x

- [ ] 3.1 In `scripts/test-template-scripts.sh`, make the stub log `HOME`, then assert that the reference comes from `init --scope project --tools agents --profile core`, that the stub sees a temporary `HOME` inside the check's temporary directory (never the caller's), and that fix hints name `init --scope project`. Run against the unchanged script, verify the new assertions fail, save the output in `evidence/3.1-failing-self-tests.txt`, and commit as `test(ci): ... (#47)`.
- [ ] 3.2 Implement design.md decision 5 in `scripts/check-openspec-skills.sh` and update the `init` command text in `TEMPLATE_SOURCE.md`; verify the whole self-test suite passes.

## 4. OpenSpec 2.1.1 and Ponytail ebd8654

- [ ] 4.1 Bump the OpenSpec pin to 2.1.1 in `.github/workflows/ci.yml` and both `TEMPLATE_SOURCE.md` rows, change the Node note to 22.20.0, run `openspec update` at 2.1.1 with a temporary `HOME`, add `skillsScope: project` to `openspec/config.yaml`, and verify `git diff --stat` shows only the six skills among generated files, `check-openspec-pin.sh` passes with 3 records on 2.1.1, `check-openspec-skills.sh` with `OPENSPEC_CMD="npx -y @fission-ai/openspec@2.1.1"` and a temporary `HOME` reports 7 files match, `rg -n "/openspec-|/opsx|slash command" .agents/skills/openspec-*/` finds nothing, and an interactive-free `openspec update` at 2.1.1 leaves the tree unchanged. Save the output in `evidence/`.
- [ ] 4.2 Re-vendor Ponytail at `ebd8654c2c627f721eb8f9c0d1bd4090a29f9e10`: copy the three `SKILL.md` files and `LICENSE` from that commit, verify `git diff` shows no change to them, update each `SOURCE.md` and the `TEMPLATE_SOURCE.md` row (commit, link, `v5.3.3-4-gebd8654`, date vendored 2026-11-23), and verify `check-ponytail-pin.sh` passes. Save the output in `evidence/`.

## 5. Verification and archive

- [ ] 5.1 Run `openspec validate --all --strict` at 2.1.1, `scripts/test-template-scripts.sh`, every `scripts/check-*.sh` (the generated-skills check with OpenSpec 2.1.1), actionlint, gitleaks over the full history, `scripts/check-commits.sh` and `git diff --check`; verify all pass and save the output in `evidence/`.
- [ ] 5.2 Run a mutation pass on the new conditions in `check-openspec-pin.sh` and `check-openspec-skills.sh` (each mutant flips one condition) and verify every mutant fails at least one self-test; save the results in `evidence/`, and add a failing-first test for any survivor before fixing it.
- [ ] 5.3 Run the Ponytail review on `git diff main...HEAD`, fix every must-fix finding, and save the review in `evidence/`.
- [ ] 5.4 With every other task checked and the pull request open with green `template-checks` and `project`, archive the change with `openspec archive update-template-openspec-2-1-1` (no `--yes`) as the last commit on the branch, verify `openspec validate --all --strict` passes after archive and the merged specs hold the modified requirements, and rerun the suite on that head.

## Workflow follow-up

- Open the pull request with `Closes #47`, full-SHA links to the change folder, "Workflow files changed: yes", the requirement and scenario to test map, the approval records and CI links.
- After the archive commit, ask Principal QA for the verdict (COMMENT review, first line `Independent QA by <reviewer>: ...`) on that head and verify `qa-gate` is green. If QA fix commits land after the archive, add them to the same branch, update the archived folder and merged specs in a further commit if the fixes change what they describe, and ask QA to re-review the new head.
