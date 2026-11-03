# Tasks

## 1. Preconditions

- [x] 1.1 Record Woody's approval of this proposal in `proposal.md` (exact words or selected option, where and when) and verify the record is committed before any other task starts.
- [x] 1.2 Re-check upstream on the day of apply: `npm view @fission-ai/openspec dist-tags.latest` and the latest `DietrichGebert/ponytail` release tag and upstream `HEAD`; verify they are still 1.16.0, v5.3.3 and `96608e078b2d5ea607c5c3b8b5a54d1c1fba6846`. If any moved, stop and report so the proposal can be updated and re-approved.

## 2. OpenSpec 1.16.0

- [x] 2.1 Bump `@fission-ai/openspec@1.14.3` to `1.16.0` in `.github/workflows/ci.yml` and in both `TEMPLATE_SOURCE.md` rows (sources and tool pins, naming `openspec update` and the Node 22.12.0 floor), and verify `rg -n "1\.14\.3"` outside `openspec/changes/archive/` finds nothing.
- [x] 2.2 Run `openspec update` with OpenSpec 1.16.0 and verify `git diff --stat .agents/skills/openspec-*` shows exactly six one-line changes (`generatedBy: "1.16.0"`) and no added or removed file; stop if it shows more.

## 3. Ponytail upstream HEAD 96608e0

- [x] 3.1 Copy `skills/ponytail/SKILL.md`, `skills/ponytail-review/SKILL.md`, `skills/ponytail-audit/SKILL.md` and `LICENSE` from `DietrichGebert/ponytail` at `96608e078b2d5ea607c5c3b8b5a54d1c1fba6846` byte for byte into the three vendored folders, and verify each `sha256sum` equals the upstream file's.
- [x] 3.2 Update each vendored `SOURCE.md` (pinned commit, upstream version `v5.3.3-1-g96608e0`, file link, date vendored, SHA-256 of `SKILL.md` and of `LICENSE`) and the Ponytail row of `TEMPLATE_SOURCE.md`, and verify `rg -n "09c434a"` outside `openspec/changes/archive/` finds nothing and every recorded SHA-256 matches the file.

## 4. Checks and review

- [ ] 4.1 Run `openspec validate --all --strict` at 1.16.0, `scripts/test-template-scripts.sh`, `scripts/check-em-dash.sh`, `scripts/check-workflows.sh`, actionlint, gitleaks over the full history, `scripts/check-commits.sh` and `git diff --check` at the head, verify all pass, and save the output in the change folder's `evidence/`.
- [ ] 4.2 After 4.1 and after the pull request (follow-up below) is open with green CI, archive the change with `openspec archive update-template-deps-2026-11` (no `--yes`) as the last commit of the implementation pull request, and verify `openspec/specs/agent-guidance/spec.md` holds the modified requirement with both scenarios.

## Workflow follow-up

- Open the pull request before 4.2 with `Closes #<issue>`, the change folder link, the Notion Tasks row, "Workflow files changed: yes", the scenario-to-check map, the approval record and CI links, and verify `template-checks` (log shows OpenSpec 1.16.0) and `project` are green.
- After the archive commit, ask Principal QA for the verdict (COMMENT review, first line `Independent QA by <reviewer>: ...`) on that head and verify `qa-gate` is green. If QA fix commits land after the archive commit, add them to the same branch, update the archived folder and merged spec in a further commit if the fixes change what they describe, and ask QA to re-review the new head.
- Merge only after QA `SHIP` on the current head and Woody's merge OK, squash-merged with a subject ending in `(#<issue>)` and `Closes #<issue>`.
