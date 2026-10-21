# Tasks

## 1. Approval and inputs

- [ ] 1.1 Record Woody's implementation approval and his answers to Decisions 1 to 7 (exact words, where and when) in proposal.md, update any artifact his answers change, and verify `openspec validate bootstrap-repo-template --strict` passes
- [ ] 1.2 Re-read openspec-sandbox `AGENTS.md` and the Ponytail skill folders from PR #1's merge commit (or latest head if unmerged), record the SHA, and verify the SHA resolves with `git ls-remote`
- [ ] 1.3 Re-resolve every pin in design.md with `gh api` and verify each recorded SHA matches its tag (record and justify any change)

## 2. Agent guidance

- [ ] 2.1 Write `AGENTS.md` per design D8 and verify every agent-guidance and branch-governance merge-rule scenario by reading the file against the spec, listing section by section
- [ ] 2.2 Write `CLAUDE.md` with `@AGENTS.md` and a one-line pointer, and verify it states no other rule
- [ ] 2.3 If Decision 2 is A, copy the three Ponytail folders byte for byte from the recorded source and verify their SHA-256 values match the source
- [ ] 2.4 Write `TEMPLATE_SOURCE.md` (template version placeholder for the template itself, AGENTS.md source SHA, Ponytail SHA, tool licenses) and verify every path it names exists

## 3. Template checks

- [ ] 3.1 Write `scripts/check-em-dash.sh` per D2 and verify it fails on a temporary file containing U+2014 and passes on the clean tree, ignoring generated and vendored paths
- [ ] 3.2 Write `scripts/check-workflows.sh` (SHA pins with version comments, `timeout-minutes` on every job, no `pull_request_target`, top-level `contents: read`) and verify it fails on a temporary unpinned workflow and passes on the real ones
- [ ] 3.3 Write `scripts/check-commits.sh` per D2 and verify it passes on this branch's commits and fails on a temporary commit without `(#N)`
- [ ] 3.4 Write `scripts/slot.sh` per D1 and verify it exits 0 with a warning when `GITHUB_REPOSITORY=OutcomefocusAi/repo-template` and exits 1 for any other value
- [ ] 3.5 Run `shellcheck` if available, otherwise `bash -n`, on every script and record which one ran

## 4. CI workflow

- [ ] 4.1 Write `.github/workflows/ci.yml` with `template-checks` and `project` jobs per D1 and D2 (pins from 1.3, concurrency, timeouts, `contents: read`) and verify `scripts/check-workflows.sh` and a pinned actionlint run pass locally
- [ ] 4.2 Push the branch and verify the CI run on the pull request passes, with the five slot warnings visible in the run annotations (link the run)

## 5. Traceability scaffolding

- [ ] 5.1 Write issue forms (`change.yml`, `docs-change.yml`, `bug.yml`) and `ISSUE_TEMPLATE/config.yml` with blank issues off, and verify GitHub renders the forms in the new-issue chooser (screenshot or `gh api` contents check)
- [ ] 5.2 Write `.github/pull_request_template.md` with every field in the change-traceability spec and verify by opening a draft pull request body from it
- [ ] 5.3 Write `.github/workflows/qa-gate.yml` per D3 and verify on this pull request: status fails with no verdict, fails for a verdict naming an old SHA, and passes only after QA's SHIP for the head (link runs)
- [ ] 5.4 Write `.github/workflows/main-guard.yml` per D3 and verify with actionlint; its live behavior is verified in 9.2 after merge
- [ ] 5.5 Apply repository merge settings per D3 with `gh api -X PATCH` and verify with `gh api repos/OutcomefocusAi/repo-template --jq '{allow_squash_merge,allow_merge_commit,allow_rebase_merge,delete_branch_on_merge}'`

## 6. Security scaffolding

- [ ] 6.1 Write `.githooks/pre-commit` per D4 and verify it blocks a staged fake credential, passes a clean commit, and fails closed when gitleaks is not on PATH
- [ ] 6.2 Add the checksum-verified gitleaks scan to `template-checks` and verify it passes on the branch and fails when the expected checksum is altered in a scratch copy
- [ ] 6.3 Write `.github/dependabot.yml` per D5 and verify GitHub accepts it (no configuration error on the repository's Dependabot page or API)
- [ ] 6.4 Write `.env.example` and `.gitignore` per D10 and verify `git check-ignore .env .env.local` matches and `.env.example` is tracked
- [ ] 6.5 Write `SECURITY.md` and verify it covers private reporting and revoke-then-rotate

## 7. Release, deploy and hygiene files

- [ ] 7.1 Write `release-please-config.json`, `.release-please-manifest.json`, `version.txt`, and `.github/workflows/release.yml` per D6 and verify actionlint passes and only the release job has write permissions
- [ ] 7.2 Write `netlify.toml` per D7 and verify it parses as TOML (`python3 -c "import tomllib"` load) and that gitleaks finds nothing in it
- [ ] 7.3 Write `CODEOWNERS` (per Decision 4) and `.editorconfig`, and verify GitHub reports no CODEOWNERS errors (`gh api repos/OutcomefocusAi/repo-template/codeowners/errors`)

## 8. README and drift control

- [ ] 8.1 Write `template-manifest.txt` and `scripts/template-drift.sh` per D9 and verify it exits 0 against the current branch and 1 after changing one managed file in a scratch clone
- [ ] 8.2 Replace README with start-a-new-repository steps, hook setup, slot filling, drift check, minutes note, and the enforcement statement from the branch-governance spec, and verify each command in it runs as written in a scratch directory (except `gh repo create`, which is shown, not run)
- [ ] 8.3 Run `scripts/check-em-dash.sh`, `openspec validate bootstrap-repo-template --strict`, and `openspec validate --all --strict` and record the output in the pull request

## 9. Verification and handoff

- [ ] 9.1 Run the Ponytail review on `git diff main...HEAD` if Decision 2 is A, fix must-fix findings, then request Principal QA with the head SHA and evidence map (every scenario to its check or run link)
- [ ] 9.2 After Woody merges, verify on `main`: CI green, `main-guard` green for the squash merge, release-please opened its release pull request (or record the org-setting failure for Woody)

## Workflow follow-up

- Woody merges the release pull request to tag `v0.1.0`, then the change is archived with `openspec archive bootstrap-repo-template` (no `--yes`).
- Create the first derived repository only as its own approved change.
