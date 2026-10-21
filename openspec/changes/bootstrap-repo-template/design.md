# Design: bootstrap-repo-template

## Context

See proposal.md for why. Current state on branch `1-bootstrap-repo-template`:

- `OutcomefocusAi/repo-template` exists, private, `is_template: true`, org plan `free` (from `gh api orgs/OutcomefocusAi`: `"plan":{"name":"free"}`). The only GitHub identity is `AgileKnow23` (org admin), shared by every agent.
- `main` has one commit, `33bae47`, a README stub. OpenSpec 1.14.3 was initialized with `openspec init --tools agents`; the generated `openspec/config.yaml` and six skills are byte-identical to openspec-sandbox.
- Source for `AGENTS.md`: openspec-sandbox PR #1, head `ff86c64` at the time of writing (it includes the Principal QA fixes: verdict comment format, order of authority with generated skills, `git diff main...HEAD`, relayed-approval sourcing, archive without `--yes`). PR #1 is not merged.
- Tools on the box: gitleaks 8.30.1, node, npm, python3, uv, jq. Not on the box: actionlint, pre-commit. Nothing was installed for this proposal.

### Research findings (fetched live 2026-10-21)

1. Branch protection, private repo, Free org. https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-protected-branches/about-protected-branches : "Protected branches are available in public repositories with GitHub Free and GitHub Free for organizations. Protected branches are also available in public and private repositories with GitHub Pro, GitHub Team, GitHub Enterprise Cloud, and GitHub Enterprise Server."
2. Rulesets. https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-rulesets/about-rulesets : "Rulesets are available in public repositories with GitHub Free and GitHub Free for organizations, and in public and private repositories with GitHub Pro, GitHub Team, and GitHub Enterprise Cloud." This matches the 403 seen on openspec-sandbox ("Upgrade to GitHub Pro or make this repository public").
3. Admin bypass. Same protected-branches page: "By default, the restrictions of a branch protection rule don't apply to people with admin permissions to the repository". With one shared admin account, even paid protection needs "Do not allow bypassing the above settings" turned on to bind agents.
4. Code owners. https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/customizing-your-repository/about-code-owners : "You can define code owners in public repositories with GitHub Free and GitHub Free for organizations, and in public and private repositories with GitHub Pro, GitHub Team, GitHub Enterprise Cloud, and GitHub Enterprise Server."
5. Actions minutes and storage. https://docs.github.com/en/billing/concepts/product-billing/github-actions : table row "GitHub Free for organizations | 500 MB | 2,000 | 10 GB | Not applicable" (artifact storage, minutes per month, cache storage per repository). "GitHub Actions usage is free for self-hosted runners and for public repositories that use standard GitHub-hosted runners." "The use of standard GitHub-hosted runners is free: In public repositories, For GitHub Pages, For Dependabot". "If your account does not have a valid payment method on file, usage is blocked once you use up your quota."
6. Minute multipliers. The current page https://docs.github.com/en/billing/reference/actions-minute-multipliers now resolves to "Actions runner pricing" and lists per-minute rates instead of multipliers: Linux 2-core $0.006, Linux 1-core `ubuntu-slim` $0.002, Windows 2-core $0.010, macOS $0.062, and "GitHub rounds the minutes and partial minutes each job uses up to the nearest whole minute." The older multipliers (Linux 1, Windows 2, macOS 10) appear only in a search-engine copy of an older Enterprise Cloud page, not on the live Free-plan page. Whether included minutes are still consumed at those ratios is not stated on the live page; treat it as uncertain and stay Linux-only, which makes it moot.
7. GITHUB_TOKEN and release pull requests. https://docs.github.com/en/actions/how-tos/write-workflows/choose-when-workflows-run/trigger-a-workflow : "when a workflow using `GITHUB_TOKEN` creates or updates a pull request, the resulting `pull_request` event creates workflow runs in an **approval-required** state ... a user with write access to the repository can start the runs by selecting **Approve workflows to run**."
8. Template repositories. https://docs.github.com/en/repositories/creating-and-managing-repositories/creating-a-template-repository : "Branches created from a template have unrelated histories, so you cannot create pull requests or merge between the branches." So drift cannot be fixed by merging from the template; it needs a diff.
9. Netlify. https://docs.netlify.com/build/configure-builds/file-based-configuration/ : contexts `production`, `deploy-preview`, `branch-deploy`, `dev`; "settings specified in `netlify.toml` override any corresponding settings in the Netlify UI". https://docs.netlify.com/build/configure-builds/ignore-builds/ : "An exit code of `1` indicates the contents have changed and the build process continues as usual. An exit code of `0` indicates that there are no changes and the build should stop." and "The `ignore` command won't cancel a build triggered by a build hook". https://docs.netlify.com/deploy/manage-deploys/manage-deploys-overview/ : locking "by disabling auto publishing" is done in the UI Deploys list ("Lock to stop auto publishing"), not in `netlify.toml`.
10. gitleaks-action. Its README: "`GITLEAKS_LICENSE` (required for organizations, not required for user accounts)"; "Since v2.0.0 of Gitleaks-Action, the license has changed from MIT to a [license](LICENSE.txt)" (an end-user license agreement). Getting a key means a sign-up form, which Woody's no-new-accounts rule forbids.

### Pins (resolved 2026-10-21 with `gh api`)

| Tool | Version | Commit SHA | License |
| --- | --- | --- | --- |
| actions/checkout | v7.0.1 | 3d3c42e5aac5ba805825da76410c181273ba90b1 | MIT |
| actions/setup-node | v7.1.0 | 949feb2413d6458794dcd2491c4babbbce0c15c1 | MIT |
| googleapis/release-please-action | v5.0.0 | 45996ed1f6d02564a971a2fa1b5860e934307cf7 | Apache-2.0 |
| gitleaks (binary, `gitleaks_8.30.1_linux_x64.tar.gz` plus `gitleaks_8.30.1_checksums.txt`) | v8.30.1 | 83d9cd684c87d95d656c1458ef04895a7f1cbd8e | MIT |
| actionlint (binary) | v1.7.12 | 914e7df21a07ef503a81201c76d2b11c789d3fca | MIT |
| @fission-ai/openspec (npm) | 1.14.3 | n/a, exact npm version | MIT |
| Ponytail skills (Decision 2) | v5.3.2-8-g09c434a | 09c434ab73ca43761c5d8b0c5d341926c2fba710 | MIT |

The apply step re-resolves each SHA and records any change before use.

## Goals / Non-Goals

**Goals:**
- A derived repository is compliant on its first commit and cannot silently pass CI with an unfilled stack slot.
- Everything works on GitHub Free for organizations with no paid feature, no new account, and no stored credential.
- Every check is honest about whether it blocks or only flags.

**Non-Goals:**
- Choosing a language, framework, or package manager. The first project proposal in each derived repository does that.
- Linking a Netlify site, creating secrets, changing org-level settings, or upgrading the plan.
- Automatic syncing of template changes into derived repositories (detect only; each sync is its own change there).

## Decisions

### D1. Language-neutral CI with stack slots that fail outside the template

`ci.yml` has two jobs. `template-checks` runs the checks in the continuous-integration spec. `project` runs lint, typecheck, test, coverage, build; each step is a shell step whose body is a marked slot, for example `# SLOT(lint): replace with the project's lint command` followed by `scripts/slot.sh lint`. `scripts/slot.sh` prints a `::warning::` and exits 0 when `GITHUB_REPOSITORY` is `OutcomefocusAi/repo-template`, and prints `::error::` and exits 1 everywhere else.

Alternatives: slots that always pass (a derived repo could stay green forever with no tests; rejected), slots that always fail (the template's own CI is permanently red, so its checks lose meaning; rejected), a repo variable that marks the template (needs a settings change in every repo and is easy to forget; rejected). Keying on the repository name needs no configuration and survives template generation, since the name changes.

### D2. Template checks in Bash and pinned binaries

Checks are small Bash scripts under `scripts/` (Bash is allowed for glue), using `git ls-files`, `grep`, and `jq`. Em-dash check: every tracked text file except `.agents/skills/openspec-*/**`, `.agents/skills/ponytail*/SKILL.md`, `.agents/skills/ponytail*/LICENSE`, any `LICENSE`, and `CHANGELOG.md`. Pin check: every `uses:` in `.github/workflows/*.yml` that is not a local path must end in a 40-hex SHA followed by a `# vX.Y.Z` comment; every job must have `timeout-minutes`. Commit check on pull requests: each commit subject in `base..head` matches `^(feat|fix|docs|chore|refactor|test|ci|build|perf|style|revert)(\(.+\))?!?: .+ \(#[0-9]+\)$`, with the issue part skipped for Dependabot and `release-please--*` branches. actionlint and gitleaks are downloaded at the pinned version and checked with `sha256sum -c` against the release's checksums file before running. OpenSpec is installed in CI with `npm install -g @fission-ai/openspec@1.14.3` after setup-node pinned to the current Node LTS release (exact version chosen and recorded at apply).

Alternatives: a Node or Python checker (adds a runtime and lockfile to a language-neutral template; rejected); third-party lint actions (more pins and wider permissions; rejected).

### D3. Free substitute for branch protection (Decision 1, recommended option A)

- `qa-gate.yml`: triggers `pull_request` (opened, synchronize, reopened) and `issue_comment` (created, edited). It never checks out code. It reads the pull request's comments through the API, finds the newest comment whose first line matches `^Independent QA by .+: (SHIP|SHIP WITH FIXES|NO-SHIP)$` and whose body contains the current head SHA, and sets a commit status `qa-gate` on the head SHA: success only for SHIP. Job permissions: `contents: read`, `pull-requests: read`, `statuses: write`. `issue_comment` runs use the workflow file on `main`, so a pull request cannot alter the gate it is judged by.
- `main-guard.yml`: on `push` to `main`, for each commit in `before..after`, calls `GET /repos/{owner}/{repo}/commits/{sha}/pulls` and fails, naming the commit, if no merged pull request contains it. Permissions: `contents: read`, `pull-requests: read`.
- Repository merge settings (applied by `gh api -X PATCH` at apply time, repo-scoped, reversible): squash merge only, pull request title as the squash subject, delete head branches on merge.
- `AGENTS.md` merge rule as in the branch-governance spec.

Trade-off: these flag but cannot block. Anyone with the shared admin account can still merge a red pull request or push to `main`; `main-guard` then turns `main` red after the fact. Because QA and the implementer post from the same GitHub account, the gate trusts the comment's content, not its author. Option B (public template) gives enforced protection and rulesets for the template only, plus free minutes, but publishes its contents. Option C (GitHub Team) gives enforcement for private repos but costs money and needs Woody's spending approval. Under B or C the same checks become required status checks with admin bypass turned off.

Minutes: each comment on a pull request triggers one short `qa-gate` run, billed as at least one minute. Expected use is well under the 2,000-minute monthly allowance; README states the cost.

### D4. Secrets: gitleaks binary, not gitleaks-action

See finding 10. CI downloads the MIT-licensed binary and verifies its checksum. The pre-commit hook (Decision 5, option A) is `.githooks/pre-commit`, enabled by `git config core.hooksPath .githooks`, running `gitleaks git --pre-commit --redact --staged --verbose` (the same entry gitleaks publishes in its `.pre-commit-hooks.yaml`). If gitleaks is missing the hook fails closed with the install hint. A `.gitleaks.toml` is added only if a template file needs an allowlist (for example `.env.example` placeholders), each entry justified in a comment.

Alternative: the `pre-commit` framework (option B), which is standard and multi-hook but requires installing a Python tool on every machine.

### D5. Dependabot

`github-actions` ecosystem, weekly, grouped into one pull request, conventional commit prefix `ci`. Commented slots for `npm`, `pip`/`uv`, and `docker`. Dependabot runs on Actions for free (finding 5). Dependabot pull requests are exempt from the issue-reference rule but still go through QA.

### D6. release-please

Release type `simple` (language-neutral: `version.txt` plus `CHANGELOG.md`), manifest mode with `release-please-config.json` and `.release-please-manifest.json` starting at `0.0.0` so the first release is `0.1.0`. The release job alone has `contents: write` and `pull-requests: write`. It uses the built-in token (Decision 6, option A); release pull request CI then waits for "Approve workflows to run" (finding 7). The template's own tags become its version numbers, which the drift check uses. The org-level "Allow GitHub Actions to create and approve pull requests" setting may need to be on; `gh api orgs/OutcomefocusAi/actions/permissions/workflow` returned 403 with the current token scopes (needs `admin:org`), so this is checked by running the workflow, and if it fails Woody is asked to flip the setting.

Alternatives: semantic-release (Node-centric, publishes by default; rejected), hand-written changelog (drifts; rejected).

### D7. Netlify preview-only

```
[build]
  ignore = "if [ \"$CONTEXT\" = \"production\" ]; then exit 0; else exit 1; fi"
  # SLOT(netlify-build): command and publish directory
[context.production]
  command = "echo 'Production deploys are disabled by repo-template policy' && exit 1"
```

Two guards: `ignore` stops production builds, and if it does not run (for example a build hook, which `ignore` does not cancel) the production command fails the build so nothing publishes. Turning off auto publishing in the Netlify UI is a third guard a derived project applies when it links a site. Uncertain: whether `CONTEXT` is set when `ignore` runs; the second guard covers that case, and the first project that links a site verifies it with a real push.

### D8. AGENTS.md assembly

Start from PR #1's merged `AGENTS.md` (or latest head, recorded by SHA in `TEMPLATE_SOURCE.md`) and change only:

- Section 1: replace the "Trivial (may skip OpenSpec)" paragraph with the docs-only waiver, quoting Woody's words and source ("OK, that works. No need to use open spec on dock changes.", 2026-10-21 11:59 AM AZ, relayed verbatim by Chief of Staff), with docs-only defined per Decision 3 and "unsure means not docs-only".
- New sections: Traceability (issue, branch, commits, pull request, QA verdict, merge, multi-PR parent issue, Notion row), Maximum effort, Stack defaults, Security (secrets, validation, OWASP Top 10, dependency audits, pinning, licenses), Observability (structured logs, error tracking, health check) and accessibility in engineering standards, Branch governance (D3, with the enforcement level stated).
- Remove nothing from PR #1's rules. Owner stays Woody (`AgileKnow23`).

Sections that are specific to one person stay in, because the template is for Woody's own org; README tells anyone reusing it outside OutcomefocusAi to edit the owner line.

### D9. Drift control

- `TEMPLATE_SOURCE.md` in every derived repository: template repo, tag, full SHA, date, plus the source of `AGENTS.md`.
- `template-manifest.txt` in the template lists template-managed paths (for example `AGENTS.md`, `CLAUDE.md`, `.github/**`, `scripts/**`, `.editorconfig`, `SECURITY.md`, `.agents/skills/**`). Files a project owns after creation (README body, `netlify.toml` slots, `CHANGELOG.md`, `version.txt`) are excluded.
- `scripts/template-drift.sh <tag>` fetches the template at that tag with `gh` (the box login can read the private template) into a temp directory and diffs the manifest paths, printing differing files and exiting 1 if any differ. It changes nothing.
- It is run on demand by an agent, for example before each project proposal. It is not a scheduled workflow, because in a private derived repository the built-in token cannot read another private repository, and adding a cross-repo token is a stored credential. If the template becomes public (Decision 1, B), a monthly scheduled check becomes possible and can be added later as its own change.

Alternatives: git subtree or a template remote (histories are unrelated, finding 8; merges are noisy), Copier/cruft (adds a Python tool and its own state file; rejected for now).

### D10. CODEOWNERS and repository hygiene

`CODEOWNERS` with `* @AgileKnow23`, with a comment that it is advisory on private Free repositories (finding 4); `.editorconfig` per the template-lifecycle spec; `.gitignore` covering env files, OS files, editor folders, and the common build and coverage outputs of the default stacks (`node_modules/`, `dist/`, `build/`, `coverage/`, `.venv/`, `__pycache__/`, `.pytest_cache/`, `.ruff_cache/`, `.netlify/`).

## Risks / Trade-offs

- [Flag-only governance on private Free] An agent can still merge or push past a red check. → Merge rule in `AGENTS.md`, `main-guard` makes violations visible, QA checks the gate before SHIP; Decision 1 B or C removes the gap.
- [Shared GitHub identity] A SHIP comment cannot be attributed to QA by author. → Verdict must name the head SHA and include evidence; Woody's merge is the final human check.
- [PR #1 still changing] The `AGENTS.md` source may change again before merge. → Apply re-reads it and records the exact SHA; if PR #1 is unmerged at apply time, the PR for this change says so.
- [Actions minutes] Comment-triggered `qa-gate` runs and CI on every push spend the shared 2,000 minutes. → Linux only, concurrency cancels superseded runs, no artifacts; README shows how to check usage. Blocked runs, not charges, follow if the quota runs out with no payment method on file (finding 5).
- [Netlify `CONTEXT` in `ignore`] Unverified. → Second guard plus UI auto-publish lock.
- [release-please org setting] Unknown. → First run tells us; asking Woody to flip one setting is the fallback.
- [Third-party pins age] → Dependabot weekly; the pin check stops unpinned additions.

## Migration Plan

New repository, nothing to migrate. Rollback: close the pull request and delete the branch; the repository itself is deleted only if Woody asks. After merge, the first release (`v0.1.0`) is the first version derived repositories can record.
