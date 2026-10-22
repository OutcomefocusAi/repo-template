# AGENTS.md

Instructions for every AI agent and tool working in this repository. This file is the single source of truth for how work is done here. Other instruction files written for this repository (such as `CLAUDE.md`) only point to this file and add no rules of their own. Vendored Ponytail skills (`.agents/skills/ponytail*/`) and OpenSpec-generated skills (`.agents/skills/openspec-*/`) are not edited here and may word things differently; where they disagree with this file, this file wins (see section 3).

As the repository-level source of truth, this file is also the template carried into every new OutcomefocusAi repository: copy it, then adjust the owner, the paths, and anything else specific to that repository.

## 1. Workflow: OpenSpec is mandatory

**Owner and approver:** Woody (GitHub `AgileKnow23`). Approval counts only in the owner's own words. An option the owner selects on an approval widget, question card, or decision card also counts as his approval when it is recorded as "option selected by <owner>" with the full option text, plus where and when he selected it. It covers only what the option text spells out; anything the option did not spell out still needs the owner's typed words. Wherever this file asks for his exact words or own words, a selected option recorded this way counts within that limit. A relay from another agent counts only if it gives his exact words (or the full text of the option he selected, marked as selected) plus where and when he wrote or selected them (for example the chat or thread, with date and time); record that quote and its source in the change's proposal or the pull request description before apply. An agent's paraphrase, summary, or inference that he would approve does not count, and neither does a quote without its source; keep waiting.

Every non-trivial change goes through OpenSpec before any implementation code is written.

**Trivial (may skip OpenSpec):** changes that alter no behavior, such as typo fixes, comment or formatting edits, and documentation wording.

**Non-trivial (needs OpenSpec):** anything that changes behavior, dependencies, interfaces, configuration, CI, or agent rules (except edits to this file under the docs waiver in section 9). When unsure, treat it as non-trivial.

**Docs-only (owner's docs waiver, section 9):** documentation changes that add no capability and change no code, configuration, or runtime behavior skip the OpenSpec proposal but keep full traceability (section 8), independent QA, and the owner's OK before merge.

Steps, in order:

1. **Explore (optional).** Think through the problem before committing to a plan. Skill: `.agents/skills/openspec-explore/SKILL.md`
2. **Propose.** Create the change with every artifact (proposal, design, spec deltas, tasks), then run `openspec validate <change> --strict` until it passes. Always name the change or use `openspec validate --all --strict`; the bare `openspec validate --strict` validates nothing and exits 1. Skill: `.agents/skills/openspec-propose/SKILL.md`. To revise a proposal: `.agents/skills/openspec-update-change/SKILL.md`
3. **Stop for owner approval.** No skill; do not write implementation code until the owner explicitly approves the proposal, as defined above. Record his exact words, with where and when he wrote them, in the proposal or the pull request description before apply.
4. **Apply task by task.** Work through `tasks.md` in order, verify each task as it says, and tick its checkbox only when it is fully done. Write code by section 2 (Ponytail, level full) and test it to section 4. Skill: `.agents/skills/openspec-apply-change/SKILL.md`
5. **Verify.** No skill; confirm every task is checked, `openspec validate <change> --strict` passes, the work matches the spec deltas, and lint, typecheck, test, and build pass where the project has them. Run the Ponytail review (section 2) on the full branch diff against the base branch (`git diff main...HEAD`).
6. **Independent QA.** No skill; ask a reviewer other than the implementing agent (for example Woody's Principal QA agent) to review the pull request. While all agents share the `AgileKnow23` GitHub account, GitHub review requests are not used: GitHub does not request a review from a pull request's own author, and an author cannot approve their own pull request. The reviewer checks the pull request against the spec and its scenarios and, before merge, posts the verdict as a pull request review of type COMMENT (or, if GitHub refuses the review, a plain pull request comment) whose first line is `Independent QA by <reviewer>: <verdict>` (`SHIP`, `SHIP-WITH-FIXES`, or `NO-SHIP`), followed by the head SHA tested and the evidence. The implementing agent reviewing its own work does not count.
7. **Archive.** After apply and verify, archive the change so its deltas move into `openspec/specs/`, as the last commit on the same implementation branch, before the independent QA `SHIP` check in step 6. QA reviews the head that includes the archive, then the owner approves the merge. The archive rides in the change's implementation pull request (for split work, the last pull request of the change); there is no separate archive pull request or issue. If QA fix commits land after the archive commit, add them to the same branch, update the archived change folder and merged specs in a further commit if the fixes change what they describe, and ask QA to re-review the new head. This order takes precedence over any post-merge timing in the archive skill. Archive only when every task in `tasks.md` is checked. Never pass `--yes` to `openspec archive` to get past an open task (it continues with only a warning). The one exception is a task the owner waives in his own words; record the waiver in `tasks.md` (his exact words, where and when he wrote them) before archiving. Skills: `.agents/skills/openspec-archive-change/SKILL.md` and, to sync specs without archiving, `.agents/skills/openspec-sync-specs/SKILL.md`

## 2. How code is written: Ponytail

Ponytail is vendored at a pinned commit in `.agents/skills/` (see each folder's `SOURCE.md`). Do not edit those copies; overrides live in this file.

- **Level:** use Ponytail at level "full" (its default). Do not use "ultra" in this repository. Use "lite" only when the owner asks for it.
- **During apply**, write code by `.agents/skills/ponytail/SKILL.md`: reuse what is already in the codebase, then the standard library and platform features, then installed dependencies, and only then the smallest new code that works. Its in-session reply rules, such as ending a reply with what you skipped and any risk, are fine to follow. Its scope questioning ("does it need to exist?") applies only at proposal time, per section 3.
- **Before QA**, run the review in `.agents/skills/ponytail-review/SKILL.md` on the full branch diff against the base branch (`git diff main...HEAD`), not only the last commit or uncommitted changes. The review only lists findings and changes no code. Then, as a separate step, fix every must-fix finding yourself. When the review judges tests, use the testing standard in section 4, not the review's "one good test" rule.
- **On demand**, when the owner asks for a repository audit, follow `.agents/skills/ponytail-audit/SKILL.md`. An audit is a report only and changes no code. Any fix it suggests is proposed as its own OpenSpec change before any code is written. When the audit judges tests, use the testing standard in section 4, not the audit's "One good test, not coverage" rule.

## 3. Precedence

When rules conflict, the higher item in this order of authority wins:

1. The owner's explicit instructions, given as defined in section 1. If one differs from the approved spec or tasks, stop. Record his exact words, or "option selected by <owner>" with the full option text (section 1), with where and when, in the proposal's Approval record; for a docs-only change under section 9, which has no proposal, record it in the pull request description. Change only the parts of the artifacts his instruction covers, run `openspec validate <change> --strict` when there is an OpenSpec change, and get his OK on the updated artifacts before apply continues.
2. The approved OpenSpec spec and tasks for the change in progress.
3. The testing standard (section 4), the non-negotiables (section 5), the engineering standards (section 6), and the conventions in sections 8 to 12.
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
- Pin dependencies to exact versions and check their licenses.
- Work trunk-based: short-lived branches off `main` (named as in section 8), merged through small pull requests focused on one change. The one exception is a stacked pull request: its branch comes off the open branch it builds on, and the pull request is retargeted to `main` after that one merges (section 8, "Split work").
- Commit messages follow Conventional Commits (for example `feat: ...`, `fix: ...`, `docs: ...`) and reference the issue (section 8).
- Tests follow the test pyramid in section 4: many unit tests, integration tests at boundaries, a few Playwright end-to-end tests on critical user journeys, and a failing test first for every bug.
- Security: validate all input, follow the OWASP Top 10, and run dependency audits.
- Observability, for anything that runs as a service: structured logs, error tracking, and a health check.
- User interfaces: WCAG 2.2 AA (section 5) and responsive layouts. Use UI and UX best practice: clear hierarchy, design tokens, an established component library (for example shadcn/ui with Tailwind), and real user flows before polish.
- Docs: a README with setup and run instructions, an architecture decision record (ADR) for each big choice, and specs kept current through the OpenSpec archive step.
- CI that runs lint, typecheck, test, and build on every push is required once the repository contains code. Until then, the checks that apply are `openspec validate <change> --strict` and the doc checks (no em dashes in hand-written files, every referenced path exists).

## 7. Writing style

Do not use em dashes in anything you write or edit by hand in this repository. Use commas, colons, parentheses, or separate sentences instead. Generated files (`.agents/skills/openspec-*`, refreshed by `openspec update`) and vendored files (`.agents/skills/ponytail*/SKILL.md` and `LICENSE`) stay exactly as their tool or upstream produced them.

## 8. Traceability

Every piece of work traces end to end, from requirement to commit.

- **Issue:** one GitHub issue per change. For an OpenSpec change, open it once the proposal validates; for a docs-only change (section 9), open it before work starts. Title it after the change, link the `openspec/changes/<change>/` folder (when there is one) and the task-tracker row for the work (when there is one), and list the `tasks.md` items (or the docs checklist) as a checklist. Put the issue URL in `proposal.md` and in the tracker row, where they exist.
- **Branch:** one branch per issue, named `<issue#>-<change-name>` (for example `12-refrigerant-log`). Never commit straight to `main`. Only the owner can waive this, for a named pull request, in his own words or a selected option (section 1), recorded as in "Owner decisions" below.
- **Commits:** Conventional Commits that reference the issue on every commit, for example `feat: add log export (#12)`. Reference the `tasks.md` item when it helps.
- **Pull request:** one per issue. The body says `Closes #<issue>`, links the change folder, maps each requirement or scenario to its test, and attaches the lint, typecheck, test, coverage, and build evidence (or says which do not apply yet and why). Ask for independent QA as in section 1 step 6: the verdict is a pull request review of type COMMENT (or a plain pull request comment if GitHub refuses the review) whose first line is `Independent QA by <reviewer>: <verdict>`, followed by the head SHA tested and the evidence.
- **Merge:** only after a `SHIP` verdict for the current head is on the pull request and the owner has approved. If any commit on the branch lacks the issue reference, squash-merge with a message that ends in `(#<issue>)` and contains `Closes #<issue>`; history is not rewritten to fix it. `SHIP-WITH-FIXES` or `NO-SHIP` means fix, then ask for QA again. Merging closes the issue. The archive is already the final commit of the change's last pull request (section 1 step 7), so no archive step follows the merge.
- **Owner decisions:** when an owner instruction changes approved scope or waives a rule here, handle it as in section 3 tier 1: stop, record his exact words or "option selected by <owner>" with the full option text (section 1), with where and when, change only what he covered, and get his OK before work continues. Record it in the proposal's Approval record; a docs-only change (section 9) has no proposal, so record it in the pull request description.
- **Split work:** if a change spans several pull requests, keep one issue per pull request and link them all to a parent issue for the change. A pull request that builds on another open one targets that branch and is retargeted to `main` after the other merges.

## 9. Docs waiver

The owner's standing waiver, written 2026-10-21 11:59 AM MST and relayed verbatim by his Chief of Staff agent: "OK, that works. No need to use open spec on dock changes." ("dock" means docs.)

- **Scope:** docs-only changes, meaning edits to `AGENTS.md` (including its agent rules), `README.md`, and other documentation that add no capability and change no code, configuration, dependencies, CI, or runtime behavior. These skip the OpenSpec proposal flow (section 1 steps 1 to 4).
- **Still required:** everything in section 8 (issue, branch, commits, and a pull request that says `Closes #<issue>` and notes the waiver), the doc checks in section 6, independent QA (section 1 step 6), and the owner's OK before merge.
- **When unsure** whether a change is docs-only, treat it as not docs-only and use OpenSpec. Code, configuration, and feature changes always use OpenSpec.

## 10. Language and stack

Pick the right tool for the job, not habit. Defaults:

- TypeScript (strict) for web, apps, and APIs (Next.js and React, Node, or Bun).
- Python 3.12+ with type hints for data, AI, and automation (uv, ruff, pytest).
- SQL and Postgres for data.
- Bash only for glue.
- Go or Rust only when performance or binary size justifies it.

Justify any deviation in the proposal. Prefer managed and serverless hosting and boring, well-supported libraries.

## 11. AI-native work

- Use AI to go faster (scaffolding, test generation, refactors, code review), but verify everything by running it.
- When building AI features: use evals with pass thresholds, version the prompts, guard against prompt injection, cap cost and tokens, and add fallbacks.
- Never ship model output that has not been tested.

## 12. Effort level

For code, features, releases, design, debugging, testing, review, and verification work in this repository, use the highest effort or reasoning level available. This includes independent QA (section 1 step 6) of every change, docs-only changes included. When handing that work to a background worker or subagent, start it at its highest effort level, never a cheaper or faster setting. When a more capable option is offered at no extra cost, pick it. Do not trade quality for speed or cost unless the owner says so.

Normal effort (the tool's default or standard level) is allowed for docs-only changes (section 9), OpenSpec archive work (section 1 step 7), and routine CI or status checks, whether an agent does that work itself or hands it to a worker. When unsure whether work is on this list, use the highest level. The effort level never changes an approval gate: proposals, independent QA, the owner's OK, and the merge rules apply the same way at any level.

No spending: never spend money, start or change a paid plan, create a new account, or accept terms of service without the owner's approval, recorded as in section 3 tier 1.

## 13. This template: tooling and branch governance

Added by `OutcomefocusAi/repo-template`; it ranks with sections 8 to 12 in section 3.

- **Secrets tooling:** enable the gitleaks pre-commit hook in every clone (`git config core.hooksPath .githooks`); CI scans the full history. `.env` is never committed; `.env.example` lists every variable with a placeholder. If a secret is exposed, revoke it first, then rotate it (`SECURITY.md`).
- **Pinning:** GitHub Actions are pinned to full commit SHAs with a version comment, and CI tool binaries to SHA-256 checksums (`TEMPLATE_SOURCE.md`).
- **Verdict:** the QA verdict line is read by the `qa-gate` check. Post a new verdict for every new head; do not edit an old verdict to change it. Only the first line counts, exactly as section 1 step 6 gives it, and any verdict-like comment or review posted at the same time or later (one whose first line contains "Independent QA by" anywhere, in any letter case) that is not a valid verdict for the head blocks the merge until a new valid verdict is posted.
- **Merge:** squash-merge with the pull request title as the subject, and make sure the subject ends with the issue reference (for example `feat: add log export (#12)`), not the pull request number GitHub appends by default.

How strongly the merge rule (section 8) is enforced depends on the repository:

- **Public repositories** (such as this template): the ruleset `protect-main` blocks direct pushes, force pushes, deletion, and merges without passing `template-checks`, `project`, and `qa-gate`, and it lists no bypass actors. No approving review is required, because every agent posts as `AgileKnow23`, the author of every pull request, and an author cannot approve their own pull request.
- **Private repositories on GitHub Free for organizations:** rulesets and branch protection are not available, so `qa-gate` and `main-guard` only flag violations with failed statuses.
- **Limits in both:** all agents share the `AgileKnow23` login and token, so any of them can post a SHIP verdict, and any holder of that token can edit the ruleset. On this template the ruleset accepts the required checks only from GitHub Actions, so a status posted directly with the token does not count; in a private repository it does. A pull request that edits `.github/workflows/` runs its own copy of `qa-gate`. These checks protect against mistakes and outsiders, not against the shared identity; the rule that only Principal QA posts verdicts, and that the owner OKs every merge, is what holds.
