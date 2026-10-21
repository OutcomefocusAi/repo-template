# Tasks

## 1. Preconditions

- [x] 1.1 Confirm Woody's approval of this proposal is recorded in `proposal.md` (exact words, where and when) and verify the record is committed before any other task starts
- [x] 1.2 Confirm `bootstrap-repo-template` is archived and `openspec/specs/branch-governance/spec.md` exists on the branch (no rebase: merge the branch that carries the archive), and verify `openspec validate align-qa-gate-requirement --strict` passes against it. Done: archived as `2026-10-21-bootstrap-repo-template` on the close-out branch (#7), brought in with a merge commit (no rebase); the archive-refusal note from validate is gone

## 2. Requirement and behavior check

- [x] 2.1 Compare the MODIFIED "QA gate check" requirement with the triggers in `.github/workflows/qa-gate.yml` on `main` and verify every listed event type appears in the workflow and no workflow trigger is missing from the requirement. Done: `pull_request` [opened, synchronize, reopened], `issue_comment` [created, edited, deleted], `pull_request_review` [submitted, edited, dismissed] all listed, none missing
- [x] 2.2 Run `scripts/test-template-scripts.sh` and verify it passes, including the trigger check and the COMMENTED, DISMISSED, deleted and pending review cases that back the new scenarios
- [x] 2.3 Search README, `AGENTS.md` section 13 and `.github/pull_request_template.md` for text saying the gate reads comments only, and verify none remains (fix any hit in this change). Done: no hits; AGENTS.md sections 1 and 8 already say a COMMENT review or a comment

## 3. Validation and review

- [x] 3.1 Run `openspec validate --all --strict` and the em-dash check and verify both pass
- [x] 3.2 Open the pull request for issue #6 with the evidence map, get Principal QA's verdict for the head, and verify `qa-gate` is green. Done: PR #9, Principal QA's [SHIP review](https://github.com/OutcomefocusAi/repo-template/pull/9#pullrequestreview-5606913650) for the merged head `a909bb4`, `qa-gate` green; squash-merged as `e8040c2`

## Workflow follow-up

- After Woody's merge OK, squash-merge with a subject ending in `(#6)`.
- Archive `align-qa-gate-requirement` and verify `openspec/specs/branch-governance/spec.md` shows the new requirement text.
