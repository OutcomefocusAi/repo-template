# Design: bootstrap-repo-template

## Context

See proposal.md for why. Current state on branch `1-bootstrap-repo-template`:

- `OutcomefocusAi/repo-template` exists, `is_template: true`, private until the pre-publication privacy check passes (Decision 1 = B makes it public), org plan `free` (from `gh api orgs/OutcomefocusAi`: `"plan":{"name":"free"}`). The only GitHub identity is `AgileKnow23` (org admin), shared by every agent.
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
- Everything works on GitHub Free for organizations with no paid feature, no new account, and no stored credential; the public template gets enforced protection, and private derived repositories get the flag-only layer.
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

### D3. Branch governance: ruleset on the public template, flag-only checks where rulesets are unavailable (Decision 1 = B)

Woody chose B: the template is public, so GitHub rulesets work on it (finding 2). Layers, strongest first:

- **Ruleset `protect-main`** on the default branch, enforcement `active`, created with `gh api -X POST repos/OutcomefocusAi/repo-template/rulesets` only after each required check has reported at least once, so the context names match. Rules: `deletion`, `non_fast_forward`, `required_linear_history`, `pull_request` with `required_approving_review_count: 0` and `allowed_merge_methods: ["squash"]`, and `required_status_checks` with contexts `template-checks`, `project`, and `qa-gate`, `strict_required_status_checks_policy: false`.
- **No approving reviews required.** Every agent posts as `AgileKnow23`, the author of every pull request, and GitHub does not let an author approve their own pull request, so a required review could never be satisfied. Independent QA is enforced through `qa-gate` instead.
- **Empty bypass list.** Not even the org admin can push to `main`, force push, or merge with a red required check. Trade-off: in an emergency (for example a broken required check), the admin has to edit or disable the ruleset, which is a visible, logged settings change, rather than silently bypassing. That friction is the point. Alternative considered: admin in the bypass list "for pull requests only", rejected because every agent is the admin.
- **`qa-gate` status.** Triggers `pull_request` (opened, synchronize, reopened) and `issue_comment` (created, edited). It never checks out pull request code. It reads the pull request's comments through the API and accepts only comments whose author login is in the allowlist in the workflow file (`AgileKnow23`), because on a public repository anyone with a GitHub account can comment. It finds the newest allowlisted comment whose first line matches `^Independent QA by .+: (SHIP|SHIP WITH FIXES|NO-SHIP)$` and whose body contains the full head SHA, then sets commit status `qa-gate` on the head: success only for SHIP. Release-please pull requests (head branch `release-please--*`) pass automatically only when every changed file is `CHANGELOG.md`, `version.txt`, or `.release-please-manifest.json`. Permissions: `contents: read`, `pull-requests: read`, `statuses: write`. `issue_comment` runs use the workflow file on `main`, so a pull request cannot change the gate its comments are judged by; a `pull_request` run uses the pull request's copy, so any change under `.github/workflows/` must be called out in the pull request and reviewed by QA.
- **`main-guard`.** Kept as defense in depth: on `push` to `main`, for each commit in `before..after`, it calls `GET /repos/{owner}/{repo}/commits/{sha}/pulls` and fails, naming the commit, if no merged pull request contains it. It catches anything that slips through while the ruleset is disabled. In private derived repositories, where rulesets are not available on GitHub Free, it and `qa-gate` are the only guards and only flag.
- **Repository merge settings** (`gh api -X PATCH`, repository-scoped, reversible): squash merge only, pull request title as the squash subject, delete head branches on merge.
- **`AGENTS.md` merge rule** as in the branch-governance spec.

Minutes: free here, because standard runners are free on public repositories (finding 5). In private derived repositories each comment triggers one short `qa-gate` run, billed as at least one minute.

Fork pull requests: on a public repository anyone can open one. Their workflows get a read-only token and no secrets (the template uses none), so `qa-gate` cannot set a status from a fork run, and first-time contributors need approval before their workflows run (GitHub default).

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

Copy openspec-sandbox `AGENTS.md` from the latest remote head of `openspec/add-agent-guidance-ponytail` (or its merge commit), record the SHA in `TEMPLATE_SOURCE.md`, keep every rule in it unchanged (including its docs waiver text, per Decision 3), and add only:

- Traceability (issue, `<issue#>-<change-name>` branch, commits referencing the issue, pull request with `Closes #N`, evidence, QA verdict, merge, multi-PR parent issue, Notion row).
- Maximum effort.
- Stack defaults.
- Security rules (secrets, validation, OWASP Top 10, dependency audits, pinning, licenses), observability (structured logs, error tracking, health check), and accessibility, added to the engineering standards.
- Branch governance (D3), stating the enforcement level for public and private repositories.

Owner stays Woody (`AgileKnow23`). README tells anyone reusing the template outside OutcomefocusAi to edit the owner line.

### D9. Drift control

- `TEMPLATE_SOURCE.md` in every derived repository: template repo, tag, full SHA, date, plus the source of `AGENTS.md`.
- `template-manifest.txt` in the template lists template-managed paths (for example `AGENTS.md`, `CLAUDE.md`, `.github/**`, `scripts/**`, `.editorconfig`, `SECURITY.md`, `.agents/skills/**`). Files a project owns after creation (README body, `netlify.toml` slots, `CHANGELOG.md`, `version.txt`) are excluded.
- `scripts/template-drift.sh <tag>` fetches the template at that tag with `gh` (the box login can read the private template) into a temp directory and diffs the manifest paths, printing differing files and exiting 1 if any differ. It changes nothing.
- It is run on demand by an agent, for example before each project proposal. It is not a scheduled workflow, because in a private derived repository the built-in token cannot read another private repository, and adding a cross-repo token is a stored credential. If the template becomes public (Decision 1, B), a monthly scheduled check becomes possible and can be added later as its own change.

Alternatives: git subtree or a template remote (histories are unrelated, finding 8; merges are noisy), Copier/cruft (adds a Python tool and its own state file; rejected for now).

### D10. CODEOWNERS and repository hygiene

`CODEOWNERS` with `* @AgileKnow23` (Decision 4 = A). On the public template GitHub reads it (finding 4) and shows the owner on each pull request; the ruleset does not require a code-owner review, because the owner is also the author of every pull request and cannot approve it. In private derived repositories on GitHub Free it has no effect. `.editorconfig` per the template-lifecycle spec; `.gitignore` covering env files, OS files, editor folders, and the common build and coverage outputs of the default stacks (`node_modules/`, `dist/`, `build/`, `coverage/`, `.venv/`, `__pycache__/`, `.pytest_cache/`, `.ruff_cache/`, `.netlify/`).

### D11. Pre-publication privacy check

Before the visibility change: `git fetch --all` plus a fetch of `refs/pull/*`, so the scan sees what the remote holds and not only the local clone (the first repository was published after a scan that missed a web merge commit); then gitleaks over every ref; and a search of every file in every commit, plus issue #1 and PR #2 bodies and comments, for postal addresses, phone numbers, email addresses other than the `AgileKnow23` noreply address, Notion IDs and URLs, Bland and AgentMail references, day-job references, and personal names other than Woody. Anything private stops the visibility change. Known, accepted public items: the GitHub handle `AgileKnow23`, the nickname "Woody", the agent role names, and the Notion Tasks row link in the issue and pull request bodies only (it opens only with workspace access; it is kept out of committed files and flagged in the publication report). Issue and pull request templates keep the Notion row as a generic placeholder.

## Risks / Trade-offs

- [Flag-only governance in private derived repositories] An agent can still merge or push past a red check there. → Merge rule in `AGENTS.md`, `main-guard` makes violations visible, QA checks the gate before SHIP; making that repository public or upgrading removes the gap.
- [Public template] Contents, issues, and comments are world-readable, and anyone can comment or fork. → Privacy check before publishing (D11), allowlisted `qa-gate` authors, no secrets in workflows.
- [Empty bypass list] A broken required check blocks all merges. → The admin edits or disables the ruleset, a visible and logged change, then restores it.
- [Shared GitHub identity] A SHIP comment cannot be attributed to QA by author. → Verdict must name the head SHA and include evidence; Woody's merge is the final human check.
- [PR #1 still changing] The `AGENTS.md` source may change again before merge. → Apply re-reads it and records the exact SHA; if PR #1 is unmerged at apply time, the PR for this change says so.
- [Actions minutes in private derived repositories] Comment-triggered `qa-gate` runs and CI on every push spend the shared 2,000 minutes. → Linux only, concurrency cancels superseded runs, no artifacts; README shows how to check usage. Blocked runs, not charges, follow if the quota runs out with no payment method on file (finding 5).
- [Netlify `CONTEXT` in `ignore`] Unverified. → Second guard plus UI auto-publish lock.
- [release-please org setting] Unknown. → First run tells us; asking Woody to flip one setting is the fallback.
- [Third-party pins age] → Dependabot weekly; the pin check stops unpinned additions.

## Migration Plan

New repository, nothing to migrate. Rollback: close the pull request and delete the branch; the repository itself is deleted only if Woody asks. After merge, the first release (`v0.1.0`) is the first version derived repositories can record.
