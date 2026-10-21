# AGENTS.md

Instructions for every AI agent and tool working in this repository. This file is the single source of truth for how work is done here. Other instruction files written for this repository (such as `CLAUDE.md`) only point to this file and add no rules of their own. Vendored Ponytail skills (`.agents/skills/ponytail*/`) and OpenSpec-generated skills (`.agents/skills/openspec-*/`) are not edited here and may word things differently; where they disagree with this file, this file wins (see section 3).

## 1. Workflow: OpenSpec is mandatory

**Owner and approver:** Woody (GitHub `AgileKnow23`). Approval counts only in the owner's own words. A relay from another agent counts only if it gives his exact words plus where and when he wrote them (for example the chat or thread, with date and time); record that quote and its source in the change's proposal or the pull request description before apply. An agent's paraphrase, summary, or inference that he would approve does not count, and neither does a quote without its source; keep waiting.

Every non-trivial change goes through OpenSpec before any implementation code is written.

**Trivial (may skip OpenSpec):** changes that alter no behavior, such as typo fixes, comment or formatting edits, and documentation wording.

**Non-trivial (needs OpenSpec):** anything that changes behavior, dependencies, interfaces, configuration, CI, or agent rules (except docs-only edits to this file under the docs waiver below). When unsure, treat it as non-trivial.

**Docs-only (owner's docs waiver):** Woody's standing waiver, written 2026-10-21 11:59 AM MST and relayed verbatim by his Chief of Staff agent: "OK, that works. No need to use open spec on dock changes." ("dock" means docs.) Docs-only changes are edits to `AGENTS.md` (including its agent rules), `README.md`, and other documentation that add no capability and change no code, configuration, dependencies, CI, or runtime behavior. They skip the OpenSpec proposal (steps 1 to 4 below) but still need a GitHub issue, a branch named `<issue#>-<change-name>`, Conventional Commits that reference the issue, a pull request that says `Closes #<issue>` and notes the waiver, independent QA (step 6), and the owner's OK before merge. When unsure whether a change is docs-only, treat it as not docs-only. Code, configuration, and feature changes always use OpenSpec.

Steps, in order:

1. **Explore (optional).** Think through the problem before committing to a plan. Skill: `.agents/skills/openspec-explore/SKILL.md`
2. **Propose.** Create the change with every artifact (proposal, design, spec deltas, tasks), then run `openspec validate <change> --strict` until it passes. Always name the change or use `openspec validate --all --strict`; the bare `openspec validate --strict` validates nothing and exits 1. Skill: `.agents/skills/openspec-propose/SKILL.md`. To revise a proposal: `.agents/skills/openspec-update-change/SKILL.md`
3. **Stop for owner approval.** No skill; do not write implementation code until the owner explicitly approves the proposal, as defined above. Record his exact words, with where and when he wrote them, in the proposal or the pull request description before apply.
4. **Apply task by task.** Work through `tasks.md` in order, verify each task as it says, and tick its checkbox only when it is fully done. Write code by section 2 (Ponytail, level full) and test it to section 4. Skill: `.agents/skills/openspec-apply-change/SKILL.md`
5. **Verify.** No skill; confirm every task is checked, `openspec validate <change> --strict` passes, the work matches the spec deltas, and lint, typecheck, test, and build pass where the project has them. Run the Ponytail review (section 2) on the full branch diff against the base branch (`git diff main...HEAD`).
6. **Independent QA.** No skill; ask a reviewer other than the implementing agent (for example Woody's Principal QA agent) to review the pull request. While all agents share the `AgileKnow23` GitHub account, GitHub review requests are not used: GitHub does not request a review from a pull request's own author, and an author cannot approve their own pull request. The reviewer checks the pull request against the spec and its scenarios and, before merge, posts the verdict as a pull request review of type COMMENT (or, if GitHub refuses the review, a plain pull request comment) whose first line is `Independent QA by <reviewer>: <verdict>` (`SHIP`, `SHIP-WITH-FIXES`, or `NO-SHIP`), followed by the head SHA tested and the evidence. The implementing agent reviewing its own work does not count.
7. **Archive.** After merge and owner sign-off, archive the change so its deltas move into `openspec/specs/`. Archive only when every task in `tasks.md` is checked. Never pass `--yes` to `openspec archive` to get past an open task (it continues with only a warning). The one exception is a task the owner waives in his own words; record the waiver in `tasks.md` (his exact words, where and when he wrote them) before archiving. Skills: `.agents/skills/openspec-archive-change/SKILL.md` and, to sync specs without archiving, `.agents/skills/openspec-sync-specs/SKILL.md`

## 2. How code is written: Ponytail

Ponytail is vendored at a pinned commit in `.agents/skills/` (see each folder's `SOURCE.md`). Do not edit those copies; overrides live in this file.

- **Level:** use Ponytail at level "full" (its default). Do not use "ultra" in this repository. Use "lite" only when the owner asks for it.
- **During apply**, write code by `.agents/skills/ponytail/SKILL.md`: reuse what is already in the codebase, then the standard library and platform features, then installed dependencies, and only then the smallest new code that works. Its in-session reply rules, such as ending a reply with what you skipped and any risk, are fine to follow. Its scope questioning ("does it need to exist?") applies only at proposal time, per section 3.
- **Before QA**, run the review in `.agents/skills/ponytail-review/SKILL.md` on the full branch diff against the base branch (`git diff main...HEAD`), not only the last commit or uncommitted changes. The review only lists findings and changes no code. Then, as a separate step, fix every must-fix finding yourself. When the review judges tests, use the testing standard in section 4, not the review's "one good test" rule.
- **On demand**, when the owner asks for a repository audit, follow `.agents/skills/ponytail-audit/SKILL.md`. An audit is a report only and changes no code. Any fix it suggests is proposed as its own OpenSpec change before any code is written. When the audit judges tests, use the testing standard in section 4, not the audit's "One good test, not coverage" rule.

## 3. Precedence

When rules conflict, the higher item in this order of authority wins:

1. The owner's explicit instructions, given as defined in section 1. If one differs from the approved spec or tasks, stop. Record his exact words, with where and when he wrote them, in the proposal's Approval record. Change only the parts of the artifacts his instruction covers, run `openspec validate <change> --strict`, and get his OK on the updated artifacts before apply continues.
2. The approved OpenSpec spec and tasks for the change in progress.
3. The testing standard (section 4), the non-negotiables (section 5), and the engineering standards (section 6).
4. Vendored Ponytail skills (`.agents/skills/ponytail*/`) and OpenSpec-generated skills (`.agents/skills/openspec-*/`). These are never edited; where they differ from anything above, the item above wins.

Scope trimming: Ponytail's "does it need to exist?" question is used only while drafting or revising a proposal, and anything left out is recorded in the proposal. During apply, never silently drop, shrink, or defer approved scope. If an approved requirement or task looks unnecessary, either implement it or stop and raise it so the proposal can be updated and re-approved.

## 4. Testing standard

This overrides Ponytail's "one small test" default. For any code added to this repository:

- Unit tests on all business logic.
- At least 80% line coverage on new code.
- At least 90% line coverage on money and other critical paths.
- Integration tests at boundaries (APIs, databases, external services, file and network I/O).
- A few Playwright end-to-end tests covering critical user journeys in any application with a UI.
- Every bug fix starts with a test that fails before the fix and passes after it.

## 5. Non-negotiables

Making code smaller never removes or weakens:

- Input validation.
- Security controls.
- Error handling.
- Accessibility. User interfaces meet WCAG 2.2 AA.

## 6. Engineering standards

- Secrets never appear in code, in config committed to the repository, or in logs. Read them from the environment or a secret store.
- Pin dependencies to exact versions.
- Commit messages follow Conventional Commits (for example `feat: ...`, `fix: ...`, `docs: ...`).
- Keep pull requests small and focused on one change.
- CI that runs lint, typecheck, test, and build is required once the repository contains code. Until then, the checks that apply are `openspec validate <change> --strict` and the doc checks (no em dashes in hand-written files, every referenced path exists).

## 7. Writing style

Do not use em dashes in anything you write or edit by hand in this repository. Use commas, colons, parentheses, or separate sentences instead. Generated files (`.agents/skills/openspec-*`, refreshed by `openspec update`) and vendored files (`.agents/skills/ponytail*/SKILL.md` and `LICENSE`) stay exactly as their tool or upstream produced them.

## 8. Traceability

Every change, including docs-only changes, traces from requirement to merge:

1. **Issue.** One GitHub issue per change, opened with the matching issue form. It links the OpenSpec change folder (or says docs-only) and the Notion Tasks row, and carries the tasks checklist.
2. **Branch.** One branch per issue, named `<issue#>-<change-name>` (for example `12-add-log-export`).
3. **Commits.** Conventional Commits that end with the issue reference, for example `feat: add log export (#12)`. CI rejects a commit without it, except on Dependabot and release-please branches.
4. **Pull request.** Its body starts from the pull request template: `Closes #<issue>`, the change folder, the Notion row, the requirement-to-test map, and the evidence (CI links and outputs, and anything not run, with why). Say whether any file under `.github/workflows/` changed.
5. **QA verdict.** Recorded on the pull request as in section 1, step 6, naming the full head SHA.
6. **Merge.** Only as section 12 allows.
7. **Split work.** If a change needs several pull requests, open one issue per pull request and link them all from a parent issue.

## 9. Maximum effort

Use the highest effort or reasoning level available for coding, design, debugging, and verification. When you hand work to a background worker or subagent, choose the highest effort setting it offers.

## 10. Stack defaults

Use these unless the change's proposal justifies something else:

- **Web, apps, and APIs:** TypeScript in strict mode.
- **Data, AI, and automation:** Python 3.12 or later with type hints, `uv` for environments and locking, `ruff` for lint and format, `pytest` for tests.
- **Data storage and queries:** SQL on Postgres.
- **Glue scripts only:** Bash.

## 11. Security, observability, and accessibility

These extend section 6 and are never weakened to make code smaller (section 5):

- **Secrets** live only in environment variables or a secret store. `.env` is never committed; `.env.example` lists every variable with a placeholder. The pre-commit hook (`git config core.hooksPath .githooks`) and CI scan for secrets with gitleaks. If a secret is exposed, revoke it first, then rotate it (see `SECURITY.md`).
- **Input validation** at every trust boundary (requests, files, messages, environment), rejecting what is not expected.
- **OWASP Top 10:** check each change against it, especially injection, broken access control, and security misconfiguration.
- **Dependencies:** pin exact versions and commit the lockfile; pin GitHub Actions to full commit SHAs with a version comment; run the stack's dependency audit in CI once the project has dependencies; add only dependencies with a license compatible with the project and record it.
- **Observability:** structured logs (no secrets or personal data in them), error tracking, and a health check for any service.
- **Accessibility:** user interfaces meet WCAG 2.2 AA.

## 12. Branch governance

Never commit or push directly to `main`. Every change reaches `main` through a pull request, merged only when all of these hold: CI passes, a SHIP verdict for the current head SHA is on the pull request (section 1, step 6), and Woody has approved where section 1 requires it. Merge with squash, using the pull request title (a Conventional Commit) as the commit subject.

How strongly this is enforced depends on the repository:

- **Public repositories** (such as this template when public): the ruleset `protect-main` blocks direct pushes, force pushes, deletion, and merges without passing `template-checks`, `project`, and `qa-gate`, with no bypass for anyone. No approving review is required, because every agent posts as `AgileKnow23`, the author of every pull request, and an author cannot approve their own pull request; `qa-gate` stands in for it.
- **Private repositories on GitHub Free for organizations:** rulesets and branch protection are not available, so `qa-gate` and `main-guard` only flag violations with failed statuses. Nothing stops a push or merge except this rule.
