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
- [ ] 4.3 Write `.github/dependabot.yml` per D5 and verify GitHub accepts it (no Dependabot configuration error reported for the repository)
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

## Workflow follow-up

- Principal QA posts its verdict; `qa-gate` turns green only on SHIP for the head.
- Woody merges PR #2. Then verify on `main`: CI green, `main-guard` green for the squash merge, release-please opened its release pull request (or record the org-setting failure for Woody).
- Woody merges the release pull request to tag `v0.1.0`, then the change is archived with `openspec archive bootstrap-repo-template` (no `--yes`).
