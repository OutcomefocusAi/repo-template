# Proposal: bootstrap-repo-template

Tracking issue: https://github.com/OutcomefocusAi/repo-template/issues/1
Notion Tasks row: none found on 2026-10-21 (read-only search of Ops HQ Tasks for "repo-template" and "template repository OutcomefocusAi OpenSpec" returned no matching row). Chief of Staff owns creating one; link it here and in the issue when it exists.

## Approval record

- Planning authorized by Woody, 2026-10-21 12:03 PM AZ (America/Phoenix), relayed verbatim by Chief of Staff in the Principal Engineer chat: "Yes, start the proposal", answering "Have Principal Engineer build a clean repo-template under OutcomefocusAi with all of this, starting with an OpenSpec proposal for you to approve?"
- This authorizes planning only. Implementation approval: pending. Record Woody's exact words, with where and when he wrote them, here before apply starts.

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
- Add a free-plan substitute for branch protection (see Decision 1), because GitHub Free does not offer branch protection or rulesets on private repositories.

## Capabilities

### New Capabilities

- `agent-guidance`: the repository-level instructions every agent and tool follows (AGENTS.md, CLAUDE.md pointer, skill locations, waivers, precedence).
- `change-traceability`: how work links requirement to commit (issue forms, branch and commit naming, pull request template, QA verdict record).
- `continuous-integration`: what runs on every pull request and push to `main`, how it is hardened, and how stack slots are filled.
- `supply-chain-security`: secrets scanning, dependency update automation, pinning, environment variable hygiene, and the security policy.
- `release-management`: changelog generation and release tagging from Conventional Commits.
- `preview-deploys`: Netlify configuration that allows previews and refuses production.
- `template-lifecycle`: template repository status, starting a new repository from it, recording the template version, and detecting drift.
- `branch-governance`: how `main` is kept to reviewed, QA-shipped pull requests without paid branch protection.

### Modified Capabilities

None. The repository has no existing specs.

## Decisions for Woody

Each has a recommendation; nothing below is implemented before he answers. Details and alternatives are in design.md.

1. **Branch protection on a private Free repository.** GitHub's docs say protected branches and rulesets are available in public repositories on GitHub Free for organizations, and in private repositories only on paid plans. Options: (A, recommended) stay private and use the free substitute: CI plus a `qa-gate` check that fails until a SHIP verdict for the current head SHA is on the pull request, a `main-guard` check that turns red when `main` receives a commit not from a merged pull request, and the AGENTS.md merge rule. It flags violations but cannot block them. (B) Make `repo-template` public: real branch protection and rulesets and free Actions minutes for this repository, at the cost of the template's contents being public (no secrets or business data are in it). Derived repositories stay private either way. (C) Upgrade the org to GitHub Team: paid, needs his spending approval.
2. **Ponytail skills.** (A, recommended) Vendor ponytail, ponytail-review, and ponytail-audit at the same pinned commit PR #1 uses, so AGENTS.md section 2 works unchanged. (B) Leave them out and remove section 2 from the template's AGENTS.md.
3. **Is an AGENTS.md rule change "docs-only"?** The waiver in my profile lists AGENTS.md as documentation. PR #1's AGENTS.md says changes to agent rules are non-trivial and need OpenSpec. (A, recommended) A change that alters what agents must do is not docs-only and uses OpenSpec; wording-only edits to AGENTS.md are docs-only. (B) All AGENTS.md edits are docs-only, as the profile text reads.
4. **CODEOWNERS.** GitHub's docs say code owners work in private repositories only on paid plans. (A, recommended) Include `* @AgileKnow23` as advisory; it starts working if the repo goes public or the plan changes. (B) Omit it, as PR #1 did.
5. **Pre-commit mechanism for gitleaks.** (A, recommended) A plain `.githooks/pre-commit` script enabled with `git config core.hooksPath .githooks`; needs only the gitleaks binary. (B) The `pre-commit` framework with gitleaks' published hook; a common standard but adds a Python tool every machine must install.
6. **release-please pull requests.** Pull requests that release-please opens with the built-in token start their CI runs in an approval-required state. (A, recommended) Accept that: Woody or an agent clicks "Approve workflows to run" on each release pull request; no new credential. (B) Create a fine-grained token or GitHub App so CI starts automatically; adds a secret to manage. Separately, the org setting that lets Actions create pull requests may need to be turned on; I cannot read it with the current token scopes.
7. **Netlify.** The template only ships `netlify.toml`. (A, recommended) No Netlify site is created or linked in this change; a derived project links its own site when Woody approves, and also turns off auto publishing in the Netlify UI as a second guard. (B) Link a site for the template itself now.

## Impact

- New repository `OutcomefocusAi/repo-template` (private, marked as a template). `main` holds only a README stub (commit `33bae47`), the one direct-to-main commit, made so a branch and pull request could exist.
- New files: `AGENTS.md`, `CLAUDE.md`, `README.md` (replaced), `SECURITY.md`, `CODEOWNERS`, `.editorconfig`, `.gitignore`, `.env.example`, `netlify.toml`, `.githooks/pre-commit`, `.gitleaks.toml` if needed, `release-please-config.json`, `.release-please-manifest.json`, `version.txt`, `TEMPLATE_SOURCE.md`, `scripts/` checks, `.github/workflows/{ci,qa-gate,main-guard,release}.yml`, `.github/dependabot.yml`, `.github/ISSUE_TEMPLATE/*`, `.github/pull_request_template.md`, and (Decision 2) `.agents/skills/ponytail*/`.
- This change folder: `openspec/changes/bootstrap-repo-template/`.
- New pinned third-party dependencies, all used only in CI or on developer machines: actions/checkout v7.0.1, actions/setup-node v7.1.0, googleapis/release-please-action v5.0.0, gitleaks v8.30.1 (binary, MIT), actionlint v1.7.12 (binary, MIT), @fission-ai/openspec 1.14.3 (MIT). gitleaks-action is deliberately not used: it is under an end-user license and requires a license key for organization repositories.
- GitHub Actions minutes: private repositories on GitHub Free for organizations get 2,000 included minutes a month, shared across the org. The template's CI is Linux-only and short.
- No spending, no new accounts, no production deploys.
