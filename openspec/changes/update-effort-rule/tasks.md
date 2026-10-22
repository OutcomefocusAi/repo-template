# Tasks

## 1. Preconditions

- [x] 1.1 Record Woody's approval of this proposal in `proposal.md` (exact words or selected option, where and when) and verify the record is committed before any other task starts. Done: `ed8f501`
- [x] 1.2 Re-read `AGENTS.md` section 12 on the latest `origin/main` and verify it still matches the text this design describes (no other pull request changed it); if it changed, stop and report before editing. Done: `origin/main` at `a766b44`; `git diff a766b44 origin/main -- AGENTS.md` is empty and section 12 is the "Maximum effort" text described in design.md (effort paragraph, then the no-spending paragraph)

## 2. Rule text

- [x] 2.1 Rewrite `AGENTS.md` section 12 to state the effort rule from the spec delta (highest level for code, features, releases, design, debugging, testing, review and verification, including independent QA and delegated workers; normal effort allowed for docs-only changes, OpenSpec archive work and routine CI or status checks; highest when unsure; approval gates unchanged), retitle it, and keep the no-spending paragraph unchanged; verify by reading the diff against each scenario in `specs/agent-guidance/spec.md` and confirming no other section changed. Done: section 12 retitled "Effort level"; first paragraph covers the highest-level list, independent QA of every change (docs-only included) and delegated workers (scenario "Agent delegates work"); second paragraph allows normal effort for docs-only, archive and routine CI or status work (scenario "Docs-only, archive, or routine CI work"), says highest when unsure ("Unsure which effort applies") and that no approval gate changes ("Approval gates unchanged"); the no-spending paragraph and every other section are unchanged in `git diff`
- [ ] 2.2 Search the repository (outside `openspec/changes/archive/`) for other text that states or cites the maximum effort rule or section 12's title, update any hand-written mention to match, and verify with `rg -n -i "effort"` that no stale wording remains.

## 3. Checks and review

- [ ] 3.1 Run `openspec validate --all --strict`, `scripts/check-em-dash.sh`, `scripts/test-template-scripts.sh`, `scripts/check-workflows.sh`, `scripts/check-commits.sh` and `git diff --check` at the head and verify all pass; save the output under the change folder's `evidence/`.
- [ ] 3.2 After 3.1 and after the pull request (follow-up below) is open with green CI, archive the change with `openspec archive update-effort-rule` (no `--yes`) as the last commit of the implementation pull request, and verify `openspec/specs/agent-guidance/spec.md` holds "AGENTS.md states the effort rule" with its four scenarios and no longer holds "AGENTS.md states the maximum effort rule".

## Workflow follow-up

- Open the pull request for the issue before 3.2, with `Closes #<issue>`, the change folder link, the scenario-to-check map, the approval record and CI links, and verify `template-checks` and `project` are green.
- After the archive commit, ask Principal QA for the verdict (COMMENT review, first line `Independent QA by <reviewer>: ...`) on that head and verify `qa-gate` is green. If QA fix commits land after the archive commit, add them to the same branch, update the archived folder and merged spec in a further commit if the fixes change what they describe, and ask QA to re-review the new head.
- Merge only after QA `SHIP` on the current head and Woody's merge OK, squash-merged with a subject ending in `(#<issue>)` and `Closes #<issue>`.
