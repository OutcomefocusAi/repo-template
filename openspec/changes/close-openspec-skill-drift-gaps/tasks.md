# Tasks

## 1. Preconditions

- [ ] 1.1 Verify Woody's approval (tapped 10:24 AM AZ Nov 16, 2026, relayed by Chief of Staff, covering this proposal and its apply for E1 and E2 only) is recorded in `proposal.md` and in #41 before any other task starts.
- [ ] 1.2 Re-check that the CI pin and npm `latest` are still 2.0.0 and reproduce E1 (`.agents/skills` and `.agents` committed as symlinks to identical copies pass, also in a fresh clone) on the current script with the real 2.0.0 CLI; save the output in `evidence/`. If anything changed, stop and report.

## 2. Self-tests first

- [ ] 2.1 Copy `mutants.sh` into `evidence/`, add `--e` (QA's D1d, D1f, D1j and an E1-check mutant), and record that D1d, D1f and D1j survive the current tests.
- [ ] 2.2 Add the E1 and E2 cases and the harness cleanup from design.md to `scripts/test-template-scripts.sh`. Verify the E1 cases fail and every other case passes, commit, and save the run in `evidence/`.

## 3. Script

- [ ] 3.1 Change `scripts/check-openspec-skills.sh` per design.md (ancestor check, shared index lookup). Verify every self-test passes and shellcheck is clean.
- [ ] 3.2 Re-run `evidence/mutants.sh . --d1 --e` and record every mutant killed except the equivalent mutant 6. On a scratch clone with the real 2.0.0 CLI, show `.agents/skills` and `.agents` committed as symlinks each fail with `symlink:`, also in a fresh clone, the clean tree passes, and `git status` is unchanged. Save the output in `evidence/`.

## 4. Checks and archive

- [ ] 4.1 Run `openspec validate --all --strict` at 2.0.0, `scripts/test-template-scripts.sh`, `scripts/check-em-dash.sh`, `scripts/check-openspec-pin.sh`, `scripts/check-openspec-skills.sh` (2.0.0), `scripts/check-ponytail-pin.sh`, `scripts/check-workflows.sh`, actionlint, shellcheck on the changed script, gitleaks over the full history, `scripts/check-commits.sh` and `git diff --check`; verify all pass and save the output in `evidence/`.
- [ ] 4.2 After 4.1 and after the pull request is open with green CI, archive in a scratch clone and run `openspec validate --all --strict` (must pass, requirement text 500 characters or fewer), then archive for real with `openspec archive close-openspec-skill-drift-gaps` at 2.0.0 (no `--yes`) as the last commit, and re-run `validate --all --strict`.

## Workflow follow-up

- Open one pull request with `Closes #41`, full-SHA links, the Notion Tasks row, the test map, the mutation table, the approval record and CI links; verify `template-checks` (log shows the drift step and its success line) and `project` are green.
- After the archive commit, ask Principal QA for the verdict on that head. Merge only on Woody's tap via Chief of Staff (not version-only), after QA `SHIP` on the current head with green CI, squash-merged with a subject ending in `(#41)`.
