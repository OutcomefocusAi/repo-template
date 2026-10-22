# Tasks

## 1. Approval, inputs and publication

- [x] 1.1 Record Woody's implementation approval and the decision answers (exact words, where and when) in proposal.md, revise design and specs for a public repository, and verify `openspec validate bootstrap-repo-template --strict` passes
- [x] 1.2 Re-resolve every pin in design.md with `gh api` and verify each recorded SHA matches its tag (record and justify any change)
- [x] 1.3 Run the pre-publication privacy check (design D11) after `git fetch --all` and a fetch of `refs/pull/*`, over every remote ref, all commits, files, issue #1 and PR #2, and verify it finds nothing private (record the commands and results in the pull request)
- [x] 1.4 Make the repository public with `gh api -X PATCH repos/OutcomefocusAi/repo-template -f visibility=public` and verify `gh api repos/OutcomefocusAi/repo-template --jq '{visibility,is_template}'` shows `public` and `true`

## 2. Template checks

- [x] 2.1 Write `scripts/check-em-dash.sh` per D2 and verify it fails on a temporary file containing U+2014 and passes on the clean tree, ignoring generated and vendored paths
- [x] 2.2 Write `scripts/check-workflows.sh` (SHA pins with version comments, `timeout-minutes` on every job, no `pull_request_target`, top-level `contents: read`) and verify it fails on a temporary unpinned workflow and passes on the real ones
- [x] 2.3 Write `scripts/check-commits.sh` per D2 and verify it passes on this branch's commits and fails on a temporary commit without `(#N)`
- [x] 2.4 Write `scripts/slot.sh` per D1 and verify it exits 0 with a warning when `GITHUB_REPOSITORY=OutcomefocusAi/repo-template` and exits 1 for any other value
- [x] 2.5 Run `shellcheck` if available, otherwise `bash -n`, on every script and record which one ran

## 3. CI workflow

- [x] 3.1 Write `.github/workflows/ci.yml` with `template-checks` (including the checksum-verified gitleaks and actionlint downloads) and `project` jobs per D1 and D2, and verify `scripts/check-workflows.sh` passes locally
- [x] 3.2 Push the branch and verify the CI run on PR #2 passes, with the five slot warnings visible in the run annotations (link the run)

## 4. Security scaffolding

- [x] 4.1 Write `.githooks/pre-commit` per D4 and verify it blocks a staged fake credential, passes a clean commit, and fails closed when gitleaks is not on PATH
- [x] 4.2 Verify the CI gitleaks step fails when the expected checksum is altered (run the download-and-verify script locally with a wrong checksum)
- [x] 4.3 Write `.github/dependabot.yml` per D5 and verify GitHub accepts it (no Dependabot configuration error reported for the repository). Verified after merge on `56975b7`: check run [`.github/dependabot.yml`](https://github.com/OutcomefocusAi/repo-template/runs/119472374367) success; first version-update job [run 39672115567](https://github.com/OutcomefocusAi/repo-template/actions/runs/39672115567) success, no updates needed; evidence on #4
- [x] 4.4 Write `.env.example` and `.gitignore` per D10 and verify `git check-ignore .env .env.local` matches and `.env.example` is tracked
- [x] 4.5 Write `SECURITY.md` and verify it covers private reporting and revoke-then-rotate

## 5. Traceability scaffolding

- [x] 5.1 Write issue forms (`change.yml`, `docs-change.yml`, `bug.yml`) and `ISSUE_TEMPLATE/config.yml` with blank issues off, Notion row as a generic placeholder, and verify each parses as YAML and is served by `gh api repos/OutcomefocusAi/repo-template/contents/.github/ISSUE_TEMPLATE?ref=<branch>`
- [x] 5.2 Write `.github/pull_request_template.md` with every field in the change-traceability spec and verify it contains each field
- [x] 5.3 Write `.github/workflows/qa-gate.yml` per D3 and verify on PR #2 that the status fails with no verdict (link the run); the SHIP path is verified when Principal QA posts its verdict
- [x] 5.4 Write `.github/workflows/main-guard.yml` per D3 and verify actionlint passes; its live behavior is verified after merge
- [x] 5.5 Apply repository merge settings per D3 with `gh api -X PATCH` and verify with `gh api repos/OutcomefocusAi/repo-template --jq '{allow_squash_merge,allow_merge_commit,allow_rebase_merge,delete_branch_on_merge}'`

## 6. Release, deploy and hygiene files

- [x] 6.1 Write `release-please-config.json`, `.release-please-manifest.json`, `version.txt`, and `.github/workflows/release.yml` per D6 and verify actionlint passes and only the release job has write permissions
- [x] 6.2 Write `netlify.toml` per D7 and verify it parses with Python `tomllib` and gitleaks finds nothing in it
- [x] 6.3 Write `CODEOWNERS` and `.editorconfig`, and verify `gh api repos/OutcomefocusAi/repo-template/codeowners/errors?ref=<branch>` reports no errors

## 7. Agent guidance

- [x] 7.1 Copy the three Ponytail folders byte for byte from the openspec-sandbox branch head and verify their SHA-256 values match the source
- [x] 7.2 Write `AGENTS.md` per design D8 from the latest openspec-sandbox `openspec/add-agent-guidance-ponytail` head (SHA recorded) and verify every agent-guidance and branch-governance merge-rule scenario against the file
- [x] 7.3 Write `CLAUDE.md` with `@AGENTS.md` and a one-line pointer, and verify it states no other rule
- [x] 7.4 Write `TEMPLATE_SOURCE.md` (template version, AGENTS.md source SHA, Ponytail SHA, tool pins and licenses) and verify every path it names exists

## 8. README and drift control

- [x] 8.1 Write `template-manifest.txt` and `scripts/template-drift.sh` per D9 and verify it exits 0 against a matching tree and 1 after changing one managed file in a scratch copy
- [x] 8.2 Replace README with start-a-new-repository steps, hook setup, slot filling, drift check, minutes note, and the enforcement statement from the branch-governance spec, and verify each local command in it runs as written in a scratch directory (`gh repo create` is shown, not run)
- [x] 8.3 Run the em-dash check, `openspec validate bootstrap-repo-template --strict`, and `openspec validate --all --strict` and record the output in the pull request

## 9. Ruleset, verification and handoff

- [x] 9.1 After `template-checks`, `project`, and `qa-gate` have each reported on PR #2, create ruleset `protect-main` per D3 and verify with `gh api repos/OutcomefocusAi/repo-template/rulesets/<id>` that enforcement is `active`, `bypass_actors` is empty, and the rules match
- [x] 9.2 Run the Ponytail review on `git diff main...HEAD`, fix must-fix findings, then update PR #2's body with the scenario-to-evidence map and CI links and request Principal QA with the head SHA

## 10. Principal QA fixes (SHIP-WITH-FIXES at 8ca7f7a)

- [x] 10.1 M2: add Principal QA's 21 adversarial qa-gate cases plus fail-closed, deleted and dismissed cases to `scripts/test-template-scripts.sh`, verify they fail first, then make `qa-gate` order verdicts by creation time and block on any later malformed verdict line, and verify all pass
- [x] 10.2 S5: restrict the release-please auto-pass to `github-actions[bot]` pull requests from this repository, with tests
- [x] 10.3 S3 and S4: concurrency on every workflow (`qa-gate` cancels superseded runs), and `check-workflows.sh` rejects flow-style `uses`, extra top-level permissions, and missing concurrency, with tests
- [x] 10.4 M3: approval record says how each approval was given; "Yes, that was my fault" moved to context; AGENTS.md copied from openspec-sandbox `main` `fd91e3b` with the selected-option rule, SHA in `TEMPLATE_SOURCE.md`
- [x] 10.5 M1 docs: README and AGENTS.md section 13 state the shared-identity limits of `qa-gate` and the ruleset
- [x] 10.6 S1, S6, S8, S9: PR template verdict wording, change-folder links pinned to a commit, squash subject in the PR body, Notion row text refreshed; shellcheck 0.11.0 clean on every script

## Workflow follow-up

- Principal QA posts its verdict; `qa-gate` turns green only on SHIP for the head.
- Woody merges PR #2. Then verify on `main`: CI green, `main-guard` green for the squash merge, release-please opened its release pull request (or record the org-setting failure for Woody).
- Woody merges the release pull request to tag `v0.1.0`, then the change is archived with `openspec archive bootstrap-repo-template` (no `--yes`).

## 11. Woody's decisions on the QA follow-ups (2026-10-21 1:25 PM MST)

- [x] 11.1 Pin the `qa-gate` required check in ruleset `protect-main` to integration 15368 and set `require_extra_approval_for_unattributed_changes` to false, keeping every other rule; save before and after in `evidence/settings-2026-10-21/`
- [x] 11.2 Turn on the repository's "Allow GitHub Actions to create and approve pull requests". At close-out it was blocked (HTTP 409, the organization setting was off) and deferred to #3 with Woody's approval (2026-10-21 1:45 PM MST, `proposal.md`). Done after the organization setting was turned on. On that card Woody first tapped "Not yet on the org setting." at 2026-10-21 3:15 PM MST (see the [#3 comment](https://github.com/OutcomefocusAi/repo-template/issues/3#issuecomment-6327983938)); his typed "Done" at 3:18 PM MST superseded it: Typed by Woody in his chat with Chief of Staff at 2026-10-21 3:18 PM MST. Card: "Have you ticked 'Allow GitHub Actions to create and approve pull requests' in the OutcomefocusAi org settings?" (after Chief of Staff gave him https://github.com/organizations/OutcomefocusAi/settings/actions). Choice: "Done". Covers: recording that the OutcomefocusAi organization setting is on, which he changed himself as an organization owner. Not covered: any other organization or repository setting, any merge. The repository setting `can_approve_pull_request_reviews` reads `true` (`default_workflow_permissions` still `read`), under Woody's 1:25 PM MST approval; release [run 39685566629](https://github.com/OutcomefocusAi/repo-template/actions/runs/39685566629) on `e8040c2` (3:18 PM MST) succeeded and opened [release PR #11](https://github.com/OutcomefocusAi/repo-template/pull/11); evidence in the [#3 comment](https://github.com/OutcomefocusAi/repo-template/issues/3#issuecomment-6327983938)
- [x] 11.3 Enable private vulnerability reporting
- [x] 11.4 Enable secret scanning and push protection
- [x] 11.5 Keep Decision 3 as written and record Woody's approval in `proposal.md`
- [x] 11.6 Align the change-traceability verdict text (`SHIP-WITH-FIXES`, COMMENT review or comment) and the release-management permission text (release job and `qa-gate` `statuses: write`, design D3); validate strictly
- [x] 11.7 Update design D3, D4, D6, README, and AGENTS.md section 13 for these settings
- [x] 11.8 Principal QA follow-ups at `a69ae89`: failing tests first for same-second ties, pending reviews, and case-insensitive blocking lines, then fix `qa-gate`; spec requirements for creation-time ordering, fail-closed lines, review handling, and the release auto-pass; align AGENTS.md section 13 and the pull request template with the "contains, any case" rule; 12:15 PM approval row no longer says widget; document the organization setting and release-please behavior meanwhile
