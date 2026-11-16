# Tasks

## 1. Preconditions

- [x] 1.1 Verify Woody's approval (tapped 11:03 AM AZ Nov 16, 2026, relayed by Chief of Staff, covering this proposal and its apply for F1 only) is recorded in `proposal.md` and in #44 before any other task starts.

## 2. Mutation demo, then tests

- [x] 2.1 Copy `mutants.sh` into `evidence/`, add `--f` (mutants 16 to 19 from design.md), and record that all four survive the current 128 self-tests.
- [ ] 2.2 Add the on-disk-only and index-only self-tests from design.md to `scripts/test-template-scripts.sh`. Verify they pass, every other case still passes, and the mutation run now kills mutants 16 to 19 (16 by the on-disk-only test, 17 to 19 by the index-only test). Save both runs in `evidence/` and commit.

## 3. Checks and archive

- [ ] 3.1 Run `openspec validate --all --strict` at 2.0.0, `scripts/test-template-scripts.sh`, `scripts/check-em-dash.sh`, `scripts/check-openspec-pin.sh`, `scripts/check-openspec-skills.sh` (2.0.0), `scripts/check-ponytail-pin.sh`, `scripts/check-workflows.sh`, actionlint, shellcheck, gitleaks over the full history, `scripts/check-commits.sh` and `git diff --check`; verify all pass and save the output in `evidence/`.
- [ ] 3.2 After 3.1 and after the pull request is open with green CI, archive in a scratch clone and run `openspec validate --all --strict` (must pass, requirement text 500 characters or fewer), then archive for real with `openspec archive test-openspec-skill-parent-dir-halves` at 2.0.0 (no `--yes`) as the last commit, and re-run `validate --all --strict`.

## Workflow follow-up

- Open one pull request with `Closes #44`, full-SHA links, the Notion Tasks row, the test map, the mutation table, the approval record and CI links; verify `template-checks` (log shows the drift step and its success line) and `project` are green.
- After the archive commit, ask Principal QA for the verdict on that head. Merge only on Woody's tap via Chief of Staff, after QA `SHIP` on the current head with green CI, squash-merged with a subject ending in `(#44)`.
