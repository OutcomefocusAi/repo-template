# Proposal: bootstrap-repo-template

Tracking issue: https://github.com/OutcomefocusAi/repo-template/issues/1
Notion Tasks row: linked from the tracking issue (kept out of committed files).

## Approval record

| What | Woody's exact words | Where and when |
| --- | --- | --- |
| Start planning | "Yes, start the proposal" (answering "Have Principal Engineer build a clean repo-template under OutcomefocusAi with all of this, starting with an OpenSpec proposal for you to approve?") | Relayed verbatim by Chief of Staff; written 2026-10-21 12:03 PM MST (America/Phoenix) |
| Implement this proposal, with Decision 1 changed | "Approved, but make repo-template public for real branch protection; other recommendations as proposed." (answering "Approve the repo-template proposal?") | Grok Bot chat, 2026-10-21 12:15 PM MST; relayed verbatim to Principal Engineer and recorded here before apply |
| Docs waiver | "OK, that works. No need to use open spec on dock changes." ("dock" means docs) | Relayed verbatim by Chief of Staff; written 2026-10-21 11:59 AM MST |
| How the waiver reads in AGENTS.md (applies to Decision 3) | "Fold the docs waiver into PR #1's spec now." (answering "How should I reconcile the docs waiver with PR #1's spec?") | Grok Bot chat with Principal Engineer, 2026-10-21 12:13 PM MST, as recorded in openspec-sandbox commit `141ca6c` |
| Rebuild the repository | "Yes, approve all three recommendations: rebuild a fresh repo-template and keep the old one private, add the workflow permission, and squash-merge PR #1 with the branch-name waiver and QA's stricter rule." (the third item refers to openspec-sandbox PR #1, not this repository) | Woody's chat with Chief of Staff, 2026-10-21 about 12:25 to 12:27 PM MST, relayed verbatim to Principal Engineer |
| The early merge of the first repository's PR #2 | "Yes, that was my fault" | Woody's chat with Chief of Staff, 2026-10-21 12:27 PM MST, relayed verbatim to Principal Engineer |
| Privacy-check wording in design D11 (option selected by Woody) | "Yes, make it generic; the old wording can stay in the edit history." | Woody's chat with Chief of Staff, 2026-10-21 12:53 PM MST, option selected by Woody, relayed verbatim to Principal Engineer |
| GitHub email privacy turned on (clears the remaining privacy-check item) | "Done" | Woody's chat with Chief of Staff, 2026-10-21 12:55 PM MST, relayed verbatim to Principal Engineer; verified by re-scanning `refs/pull/2/merge` after GitHub recomputed it |

## Rebuild (2026-10-21)

The first `OutcomefocusAi/repo-template` had its proposal-only PR #2 merged into `main` at 12:18 PM MST, before implementation, with a GitHub web merge commit authored under a personal email address rather than the noreply address. The pre-publication privacy check ran on a local clone that had not fetched that commit, so the repository was public for about three minutes (about 12:20 to 12:23 PM MST) before it was made private again. With Woody's approval above, that repository was renamed `OutcomefocusAi/repo-template-old`, kept private, and had its template flag turned off; nothing in it was deleted or force-pushed. This repository is a fresh replay of the same content with clean history: every commit is authored and committed by `AgileKnow23 <204773855+AgileKnow23@users.noreply.github.com>`, `main` again holds only the README stub, and the tracking issue and pull request are new (issue #1, pull request #2 in this repository). The privacy check (design D11) now runs after `git fetch --all` over every remote ref, including `refs/pull/*`.

## Why

Every new OutcomefocusAi project currently starts from nothing, so the rules Woody has set (OpenSpec workflow, traceability, testing bars, security, no em dashes) live in agent profiles and in one sandbox pull request instead of in the repositories themselves. A private template repository that carries those rules, plus hardened CI and security scaffolding, makes every new repository start compliant on its first commit and gives any agent or tool the same instructions.

## What Changes

- Add `AGENTS.md` carried over from openspec-sandbox PR #1 (branch `openspec/add-agent-guidance-ponytail`, read at head `ff86c64`; the final merged text is re-read at apply time) and extend it with: the TRACEABILITY rule, the MAXIMUM EFFORT rule, the docs-only OpenSpec waiver, stack defaults, engineering standards, the testing bars (80% line coverage on new code, 90% on money and critical paths, E2E on critical journeys), and security rules. Add `CLAUDE.md` containing `@AGENTS.md`.
- Keep OpenSpec 1.14.3 initialized with its generated skills in `.agents/skills/` (done on this branch by `openspec init --tools agents`, identical to openspec-sandbox).
- Add a GitHub Actions CI workflow that runs on every pull request and every push to `main`: template checks (OpenSpec validation, em-dash check on hand-written files, secrets scan, workflow lint) plus lint, typecheck, test, coverage gate, and build as clearly marked stack slots that the first project proposal in a derived repository must fill.
- Add `.github` issue forms and a pull request template carrying the traceability fields (change folder, Notion row, `Closes #N`, evidence checklist, QA verdict line with head SHA).
- Add security scaffolding: a gitleaks pre-commit hook and CI scan, Dependabot for GitHub Actions (other ecosystems as slots), `.env.example`, `.gitignore`, and `SECURITY.md`.
- Add `CODEOWNERS`, `.editorconfig`, and release-please for a Conventional Commits changelog and release tags.
- Add `netlify.toml` configured so only Deploy Previews and branch deploys build; production builds are refused.
- Replace the README stub with how to start a new repository from the template and how to keep template drift in check.
- Make the repository public (Decision 1) and protect `main` with a GitHub ruleset; keep `qa-gate` as a required check and `main-guard` as defense in depth.

## Capabilities

### New Capabilities

- `agent-guidance`: the repository-level instructions every agent and tool follows (AGENTS.md, CLAUDE.md pointer, skill locations, waivers, precedence).
- `change-traceability`: how work links requirement to commit (issue forms, branch and commit naming, pull request template, QA verdict record).
- `continuous-integration`: what runs on every pull request and push to `main`, how it is hardened, and how stack slots are filled.
- `supply-chain-security`: secrets scanning, dependency update automation, pinning, environment variable hygiene, and the security policy.
- `release-management`: changelog generation and release tagging from Conventional Commits.
- `preview-deploys`: Netlify configuration that allows previews and refuses production.
- `template-lifecycle`: template repository status, starting a new repository from it, recording the template version, and detecting drift.
- `branch-governance`: how `main` is kept to reviewed, QA-shipped pull requests, with a ruleset where the plan allows it and flag-only checks where it does not.

### Modified Capabilities

None. The repository has no existing specs.

## Decisions (answered 2026-10-21)

Details and alternatives are in design.md.

1. **Branch protection: B, make `repo-template` public.** GitHub's docs say protected branches and rulesets are available in public repositories on GitHub Free for organizations. `main` gets an active ruleset (pull request required, required status checks, no force push, no deletion, linear history, empty bypass list). `main-guard` stays as defense in depth. Standard GitHub-hosted runners are free for public repositories, so this repository's Actions minutes cost nothing. Derived repositories may still be private; there the ruleset is not available and they fall back to the flag-only checks (see design D3).
2. **Ponytail: A.** Vendor ponytail, ponytail-review, and ponytail-audit at the pinned commit openspec-sandbox uses.
3. **AGENTS.md edits and the docs waiver: follow openspec-sandbox.** Woody's later instruction "Fold the docs waiver into PR #1's spec now." produced sandbox `AGENTS.md` text that counts edits to `AGENTS.md`, including its agent rules, as docs-only when they add no capability and change no code, configuration, dependencies, CI, or runtime behavior. The template copies that text unchanged. This differs from option A in the first draft of this proposal; "other recommendations as proposed" was read as not overriding his more specific 12:13 PM instruction. Woody can say otherwise and the text changes in a follow-up.
4. **CODEOWNERS: A.** `* @AgileKnow23`. On a public repository GitHub reads it; a code-owner review is not required by the ruleset, because the only account is the author of every pull request and cannot approve its own pull request.
5. **Pre-commit: A.** Plain `.githooks/pre-commit` using the gitleaks binary.
6. **release-please: A.** Built-in token; release pull request CI starts after "Approve workflows to run".
7. **Netlify: A.** No site created or linked.

## Impact

- Repository `OutcomefocusAi/repo-template`, marked as a template, made public by Decision 1 after a privacy check of every file, commit, the issue, and the pull request. `main` holds only a README stub, the one direct-to-main commit, made so a branch and pull request could exist. Rebuilt on 2026-10-21 (see Rebuild); the first repository is kept private as `OutcomefocusAi/repo-template-old`.
- New ruleset on `main` (repository-scoped, reversible).
- New files: `AGENTS.md`, `CLAUDE.md`, `README.md` (replaced), `SECURITY.md`, `CODEOWNERS`, `.editorconfig`, `.gitignore`, `.env.example`, `netlify.toml`, `.githooks/pre-commit`, `.gitleaks.toml` if needed, `release-please-config.json`, `.release-please-manifest.json`, `version.txt`, `TEMPLATE_SOURCE.md`, `scripts/` checks, `.github/workflows/{ci,qa-gate,main-guard,release}.yml`, `.github/dependabot.yml`, `.github/ISSUE_TEMPLATE/*`, `.github/pull_request_template.md`, and (Decision 2) `.agents/skills/ponytail*/`.
- This change folder: `openspec/changes/bootstrap-repo-template/`.
- New pinned third-party dependencies, all used only in CI or on developer machines: actions/checkout v7.0.1, actions/setup-node v7.1.0, googleapis/release-please-action v5.0.0, gitleaks v8.30.1 (binary, MIT), actionlint v1.7.12 (binary, MIT), @fission-ai/openspec 1.14.3 (MIT). gitleaks-action is deliberately not used: it is under an end-user license and requires a license key for organization repositories.
- GitHub Actions minutes: free for this repository once public (standard runners). Private derived repositories draw on the org's 2,000 included minutes a month; the CI is Linux-only and short.
- Public exposure: the template's contents (including Woody's GitHub handle `AgileKnow23` and the nickname "Woody" in `AGENTS.md`) become public. Anyone with a GitHub account can open issues, comment, and fork; `qa-gate` therefore accepts verdicts only from an allowlisted author.
- No spending, no new accounts, no production deploys.
