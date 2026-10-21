# Tasks

## 1. Preconditions

- [ ] 1.1 Confirm Woody's approval of this proposal is recorded in `proposal.md` (exact words, where and when) and verify the record is committed before any other task starts
- [ ] 1.2 Confirm `bootstrap-repo-template` is archived and `openspec/specs/branch-governance/spec.md` exists on the branch (rebase-free: merge or fast-forward from `main`), and verify `openspec validate align-qa-gate-requirement --strict` passes against it

## 2. Requirement and behavior check

- [ ] 2.1 Compare the MODIFIED "QA gate check" requirement with the triggers in `.github/workflows/qa-gate.yml` on `main` and verify every listed event type appears in the workflow and no workflow trigger is missing from the requirement
- [ ] 2.2 Run `scripts/test-template-scripts.sh` and verify it passes, including the trigger check and the COMMENTED, DISMISSED, deleted and pending review cases that back the new scenarios
- [ ] 2.3 Search README, `AGENTS.md` section 13 and `.github/pull_request_template.md` for text saying the gate reads comments only, and verify none remains (fix any hit in this change)

## 3. Validation and review

- [ ] 3.1 Run `openspec validate --all --strict` and the em-dash check and verify both pass
- [ ] 3.2 Open the pull request for issue #6 with the evidence map, get Principal QA's verdict for the head, and verify `qa-gate` is green

## Workflow follow-up

- After Woody's merge OK, squash-merge with a subject ending in `(#6)`.
- Archive `align-qa-gate-requirement` and verify `openspec/specs/branch-governance/spec.md` shows the new requirement text.
