# Tasks

## 1. Preconditions

- [x] 1.1 Verify Woody's approval (typed 9:41 AM AZ Nov 16, 2026, relayed by Chief of Staff, covering this proposal and its apply for D1 and D2 only) is recorded in `proposal.md` and in #39 before any other task starts.
- [x] 1.2 Re-check that the CI pin and npm `latest` are still `@fission-ai/openspec@2.0.0`, that the 7 committed generated paths are 100644, and reproduce QA's two D1 cases (committed `chmod +x`, symlink to an identical copy) passing on the current script with the real 2.0.0 CLI; save the output in `evidence/`. If any of this changed, stop and report.

## 2. Self-tests first

- [x] 2.1 Write `evidence/mutants.sh`, which applies each of QA's 8 surviving mutants to a scratch copy of the repository and runs `scripts/test-template-scripts.sh`, and record that all 8 survive on the current tests.
- [x] 2.2 Add to `scripts/test-template-scripts.sh` the D1 cases (committed `chmod +x` on a `SKILL.md`, a committed symlink to an identical copy, an untracked symlink at a generated path) and the D2 cases from design.md (stub `STUB_INIT_MODE` and XDG logging). Verify the D1 cases fail and every other case passes, commit, and save the run in `evidence/`.

## 3. Script

- [x] 3.1 Change `scripts/check-openspec-skills.sh` per design.md (git mode per path, `symlink` and `mode` annotations with fixes, first match wins). Verify every self-test passes and shellcheck is clean.
- [x] 3.2 Re-run `evidence/mutants.sh` and record each of the 8 mutants as killed, or as equivalent with the reason. On a scratch clone with the real 2.0.0 CLI, show a committed `chmod +x` and a committed symlink each fail with the expected annotation, the clean tree passes, and `git status` is unchanged. Save the output in `evidence/`.

## 4. Docs

- [x] 4.1 Update the `TEMPLATE_SOURCE.md` sentence on `check-openspec-skills.sh` to name mode and symlink drift, and verify `scripts/check-em-dash.sh` passes.

## 5. Checks and archive

- [x] 5.1 Run `openspec validate --all --strict` at 2.0.0, `scripts/test-template-scripts.sh`, `scripts/check-em-dash.sh`, `scripts/check-openspec-pin.sh`, `scripts/check-openspec-skills.sh` (2.0.0), `scripts/check-ponytail-pin.sh`, `scripts/check-workflows.sh`, actionlint, shellcheck on the changed script, gitleaks over the full history, `scripts/check-commits.sh` and `git diff --check`; verify all pass and save the output in `evidence/`.
- [x] 5.2 After 5.1 and after the pull request is open with green CI, archive in a scratch clone and run `openspec validate --all --strict` (must pass, requirement text stays 500 characters or fewer), then archive for real with `openspec archive harden-openspec-skill-drift-check` at 2.0.0 (no `--yes`) as the last commit, and re-run `validate --all --strict`.

## Workflow follow-up

- Open one pull request with `Closes #39`, full-SHA links, the Notion Tasks row, the scenario-to-test map, the mutation table, the approval record and CI links; verify `template-checks` (log shows the drift step and its success line) and `project` are green.
- After the archive commit, ask Principal QA for the verdict on that head. Merge only on Woody's tap (not version-only), after QA `SHIP` on the current head with green CI, squash-merged with a subject ending in `(#39)`.
