# Tasks

## 1. Preconditions

- [x] 1.1 Record Woody's approval of this proposal in `proposal.md` (exact words or selected option, where and when) and verify the record is committed before any other task starts. Done: `9ad53ea`
- [x] 1.2 Confirm release PR #11 is still open, unmerged and untouched by this branch, that no tag or release exists (`gh api repos/OutcomefocusAi/repo-template/tags` and `.../releases` empty), and that the branch diff lists no `CHANGELOG.md`, `version.txt` or `.release-please-manifest.json`. Done: #11 open, unmerged, head `59f38a9`, not touched; 0 tags, 0 releases; no release files in the branch diff

## 2. Failing test first

- [x] 2.1 Add self-test fixtures for `include-component-in-tag` missing and given as the string `"false"`, plus the passing case, and extend the release check to require the JSON boolean `false`; run `scripts/test-template-scripts.sh` before the config change and verify it fails on this repository for that reason only (save the output as evidence). Done: 75/76, only "release state: this repository" fails, with "include-component-in-tag must be the JSON boolean false (... include-component-in-tag unset ...)"; the missing, `true` and string `"false"` fixtures are rejected and the boolean `false` passes; shellcheck clean; `evidence/2.1-failing-test.txt`

## 3. Fix

- [x] 3.1 Add `"include-component-in-tag": false` to the root package in `release-please-config.json` and verify the self-test passes, including the new fixtures. Done: 76/76, "release state: this repository" ok and the three include-component-in-tag fixtures rejected; `evidence/3.1-passing-test.txt`
- [ ] 3.2 Run release-please 17.6.0 offline on the new config and verify the tag and the release name are both `v0.1.0`, the release branch is unchanged and the title is `chore(main): release 0.1.0`; save the output in the change folder
- [ ] 3.3 Verify the self-test passes with #11's release files over the branch (temporary worktree, nothing pushed)

## 4. Validation, CI evidence and review

- [ ] 4.1 Run `openspec validate --all --strict`, the self-test, the em-dash check, `check-workflows`, `check-commits`, actionlint, shellcheck and gitleaks at the head, and verify all pass
- [ ] 4.2 Open the pull request for #18 with the scenario-to-test map and CI run links, verify `template-checks` and `project` are green, and get Principal QA's verdict (COMMENT review, first line `Independent QA by <reviewer>: ...`) for the head with `qa-gate` green

## Workflow follow-up

- After Woody's merge OK, squash-merge with a subject ending in `(#18)` and `Closes #18`.
- After release-please rebuilds #11 on that push: approve its workflow runs (Woody's 3:30 PM rule) and verify template-checks, project and qa-gate pass, its files are still the three release files at 0.1.0, and its title is `chore(main): release 0.1.0`. #11 merges only on Woody's buttons; afterwards verify tag `v0.1.0` and release `v0.1.0`.
- Archive `fix-release-tag-name` in its own issue and verify `openspec/specs/release-management/spec.md` carries the new scenarios.
