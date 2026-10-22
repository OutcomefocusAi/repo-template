# Tasks

## 1. Preconditions

- [x] 1.1 Record Woody's approval of this proposal in `proposal.md` (exact words or selected option, where and when) and verify the record is committed before any other task starts. Done: `928b804`
- [x] 1.2 Confirm PR #11 is still open and untouched by this branch, and verify `git diff origin/main --name-only` on the branch lists no `CHANGELOG.md`, `version.txt` or `.release-please-manifest.json`. Done: #11 open at `7cd0555`, not touched; the branch diff has no release files

## 2. Failing test first

- [x] 2.1 Add self-test fixtures for pre-release (`0.0.0`, no changelog), first release `0.1.0`, later release `0.2.0` with a linked heading, manifest and `version.txt` disagreeing, changelog heading disagreeing, and `bump-minor-pre-major` missing; run `scripts/test-template-scripts.sh` against the current check and verify the release fixtures fail (save the output as evidence). Done: 68/72, the four release fixtures fail against the old check (0.1.0 and 0.2.0 rejected with the CI message, inherited changelog and missing `bump-minor-pre-major` accepted); `evidence/2.1-failing-test.txt`

## 3. Fix

- [x] 3.1 Replace the release check with the state-aware check (design decision 1) and verify every fixture from 2.1 gives the expected result and the suite passes on the branch (pre-release state). Done: every fixture as expected, each rejection names its reason; 72/72 once 3.2 set the key (before 3.2 only "this repository" failed, on `bump-minor-pre-major must be true`); `evidence/3.1-passing-test.txt`
- [x] 3.2 Set `"bump-minor-pre-major": true` in `release-please-config.json` and verify the self-test asserts it. Done: the "bump-minor-pre-major not set" fixture and the check on this repository both require `true`. QA D1: the check now requires the JSON boolean (a string "true" is rejected, since release-please ignores it): failing fixture `6d6fd74`, fix `631eef6`; `evidence/qa-d1-failing-test.txt`, `evidence/qa-d1-passing-test.txt`
- [x] 3.3 Run release-please 17.6.0 version calculation offline and verify `feat!:` on `0.1.0` gives `0.2.0`, `Release-As: 1.0.0` gives `1.0.0`, and a `0.0.0` manifest gives `0.1.0`; save the output in the change folder. Done: with this branch's config `feat!:` and a BREAKING CHANGE footer on 0.1.0 give 0.2.0 (main's config gives 1.0.0), `Release-As: 1.0.0` gives 1.0.0, no release gives 0.1.0; `evidence/3.3-release-please-versions.txt`
- [x] 3.4 Run the self-test against the files of release PR #11's head (`CHANGELOG.md`, `version.txt`, `.release-please-manifest.json` copied into a scratch checkout, not pushed) and verify it passes. Done: 72/72 with the 7cd0555 release files over the branch (old check on the same files: 62/63, the PR #11 failure); `evidence/3.4-release-pr-state.txt`
- [x] 3.5 Add the release-state reset step to README "start a new repository" and verify, on a scratch copy of the template with those files at `0.1.0`, that following the step leaves `0.0.0` and no `CHANGELOG.md`. Done: README step 4 (later steps renumbered); on the scratch copy the manifest and `version.txt` go from 0.1.0 to 0.0.0, `CHANGELOG.md` is removed, the release check passes and release-please gives 0.1.0; `evidence/3.5-readme-reset.txt`

## 4. Validation, CI evidence and review

- [x] 4.1 Run `openspec validate --all --strict`, the self-test, the em-dash check, `check-workflows`, `check-commits` and gitleaks, and verify all pass. Done: retaken after the QA fixes on the tree committed as the PR head: all pass, also actionlint and shellcheck (clean, as on main); on the merge result with main: validate 9/9 and the self-test; `evidence/4.1-checks.txt`
- [x] 4.2 Open the pull request for the issue with the scenario-to-test map and CI run links, verify `template-checks` and `project` are green, and get Principal QA's verdict (COMMENT review, first line `Independent QA by <reviewer>: ...`) for the head with `qa-gate` green. QA round 1: SHIP-WITH-FIXES at `6894c82` ([review](https://github.com/OutcomefocusAi/repo-template/pull/15#pullrequestreview-5607115446)); D1 to D3 fixed on the branch before round 2. QA round 2: Principal QA's [SHIP review](https://github.com/OutcomefocusAi/repo-template/pull/15#pullrequestreview-5607172900) for `43e0a0a`; CI green ([run 39688821777](https://github.com/OutcomefocusAi/repo-template/actions/runs/39688821777)), `qa-gate` green; squash-merged as `ad660e4`

## Workflow follow-up

- After Woody's merge OK, squash-merge with a subject ending in `(#<issue>)` and `Closes #<issue>`.
- After the next push to `main` rebuilds release PR #11, someone clicks "Approve workflows to run"; verify its `template-checks` passes. #11 merges only on Woody's buttons.
- Archive `fix-first-release-check` and verify `openspec/specs/release-management/spec.md` and `openspec/specs/template-lifecycle/spec.md` carry the new scenarios.
