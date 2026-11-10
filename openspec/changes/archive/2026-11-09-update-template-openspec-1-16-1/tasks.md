# Tasks

## 1. Preconditions

- [x] 1.1 Record Woody's approval of this proposal in `proposal.md` (card, selected option or exact words, where and when, covers and not covered), including the 1.17.0 retarget and the approval to apply it, with the 1.16.1 approval marked superseded, and verify the record is committed before any other task starts.
- [x] 1.2 Re-check upstream on the day of apply: `npm view @fission-ai/openspec dist-tags.latest` and `DietrichGebert/ponytail` upstream `HEAD`; verify npm `latest` is still 1.17.0 and Ponytail `HEAD` is still `96608e078b2d5ea607c5c3b8b5a54d1c1fba6846`, and save the output in `evidence/`. If either moved, stop and report so the proposal can be updated and re-approved.

## 2. OpenSpec 1.17.0

- [x] 2.1 Bump `@fission-ai/openspec@1.16.0` to `1.17.0` in `.github/workflows/ci.yml` and in both `TEMPLATE_SOURCE.md` rows (Sources and Tool pins), and verify `rg -n "1\.16\.0"` outside `openspec/changes/` finds only the six generated skills.
- [x] 2.2 Run `openspec update` with OpenSpec 1.17.0 and verify `git diff --stat .agents/skills/openspec-*` shows exactly six one-line changes (`generatedBy: "1.17.0"`) and no added or removed file; stop if it shows more. Then verify `rg -n "1\.16\.0"` outside `openspec/changes/` finds nothing and the four version records agree (the new "OpenSpec pin records agree" scenario).

## 3. Checks and archive

- [x] 3.1 Run `openspec validate --all --strict` at 1.17.0, `scripts/test-template-scripts.sh`, `scripts/check-em-dash.sh`, `scripts/check-workflows.sh`, actionlint, gitleaks over the full history, `scripts/check-commits.sh` and `git diff --check` at the head, verify all pass, and save the output in the change folder's `evidence/`.
- [x] 3.2 After 3.1 and after the pull request (follow-up below) is open with green CI, archive the change with `openspec archive update-template-openspec-1-16-1` (no `--yes`) as the last commit of the implementation pull request, before Principal QA reviews, and verify `openspec/specs/agent-guidance/spec.md` holds the modified requirement with both scenarios.

## Workflow follow-up

- Open the pull request before 3.2 with `Closes #30`, full-SHA links to the change folder, the Notion Tasks row, "Workflow files changed: yes", the scenario-to-check map, the approval record and CI links, and verify `template-checks` (log shows OpenSpec 1.17.0) and `project` are green.
- After the archive commit, ask Principal QA for the verdict (COMMENT review, first line `Independent QA by <reviewer>: ...`) on that head and verify `qa-gate` is green. If QA fix commits land after the archive commit, add them to the same branch, update the archived folder and merged spec in a further commit if the fixes change what they describe, and ask QA to re-review the new head.
- Merge only after QA `SHIP` on the current head with green CI, squash-merged with a subject ending in `(#30)` and `Closes #30`.
