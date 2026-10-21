# Tasks

## 1. Preconditions

- [x] 1.1 Record Woody's approval of this proposal in `proposal.md` (exact words or selected option, where and when) and verify the record is committed before any other task starts. Done: `928b804`
- [x] 1.2 Confirm PR #11 is still open and untouched by this branch, and verify `git diff origin/main --name-only` on the branch lists no `CHANGELOG.md`, `version.txt` or `.release-please-manifest.json`. Done: #11 open at `7cd0555`, not touched; the branch diff has no release files

## 2. Failing test first

- [x] 2.1 Add self-test fixtures for pre-release (`0.0.0`, no changelog), first release `0.1.0`, later release `0.2.0` with a linked heading, manifest and `version.txt` disagreeing, changelog heading disagreeing, and `bump-minor-pre-major` missing; run `scripts/test-template-scripts.sh` against the current check and verify the release fixtures fail (save the output as evidence). Done: 68/72, the four release fixtures fail against the old check (0.1.0 and 0.2.0 rejected with the CI message, inherited changelog and missing `bump-minor-pre-major` accepted); `evidence/2.1-failing-test.txt`

## 3. Fix

- [ ] 3.1 Replace the release check with the state-aware check (design decision 1) and verify every fixture from 2.1 gives the expected result and the suite passes on the branch (pre-release state)
- [ ] 3.2 Set `"bump-minor-pre-major": true` in `release-please-config.json` and verify the self-test asserts it
- [ ] 3.3 Run release-please 17.6.0 version calculation offline and verify `feat!:` on `0.1.0` gives `0.2.0`, `Release-As: 1.0.0` gives `1.0.0`, and a `0.0.0` manifest gives `0.1.0`; save the output in the change folder
- [ ] 3.4 Run the self-test against the files of release PR #11's head (`CHANGELOG.md`, `version.txt`, `.release-please-manifest.json` copied into a scratch checkout, not pushed) and verify it passes
- [ ] 3.5 Add the release-state reset step to README "start a new repository" and verify, on a scratch copy of the template with those files at `0.1.0`, that following the step leaves `0.0.0` and no `CHANGELOG.md`

## 4. Validation, CI evidence and review

- [ ] 4.1 Run `openspec validate --all --strict`, the self-test, the em-dash check, `check-workflows`, `check-commits` and gitleaks, and verify all pass
- [ ] 4.2 Open the pull request for the issue with the scenario-to-test map and CI run links, verify `template-checks` and `project` are green, and get Principal QA's verdict (COMMENT review, first line `Independent QA by <reviewer>: ...`) for the head with `qa-gate` green

## Workflow follow-up

- After Woody's merge OK, squash-merge with a subject ending in `(#<issue>)` and `Closes #<issue>`.
- After the next push to `main` rebuilds release PR #11, someone clicks "Approve workflows to run"; verify its `template-checks` passes. #11 merges only on Woody's buttons.
- Archive `fix-first-release-check` and verify `openspec/specs/release-management/spec.md` and `openspec/specs/template-lifecycle/spec.md` carry the new scenarios.
