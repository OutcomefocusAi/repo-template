# Design: align-qa-gate-requirement

## Context

See `proposal.md`, Why. The behavior is already implemented on `main` (`56975b7`): `.github/workflows/qa-gate.yml` triggers on `pull_request` (opened, synchronize, reopened), `issue_comment` (created, edited, deleted), and `pull_request_review` (submitted, edited, dismissed), and reads both comments and reviews. `scripts/test-template-scripts.sh` checks the trigger lists and runs the verdict filter against comment and review items (COMMENTED, DISMISSED, PENDING). The change-traceability capability already has "QA gate review handling" and the ordering and fail-closed requirements. Only the branch-governance requirement text lags.

## Goals / Non-Goals

**Goals:**
- Make the branch-governance "QA gate check" requirement match the workflow and the change-traceability requirements, with no change in behavior.

**Non-Goals:**
- Any change to `qa-gate.yml`, scripts, the ruleset, or repository settings.
- Moving the review-handling, ordering, or release auto-pass rules from change-traceability into branch-governance. They stay where they are; this requirement refers to the verdict and triggers only.
- The release-please initial version (1.0.0 instead of 0.1.0, found on the first `main` run) and the organization setting in #3. Those are separate changes.

## Decisions

- **MODIFIED, not ADDED.** The existing requirement is wrong rather than incomplete, so the whole block is restated under MODIFIED with its five scenarios kept (wording adjusted for "comment or review") and two scenarios added. Alternative: add a new requirement and leave the old text; rejected because two requirements would contradict each other.
- **Triggers listed in the requirement.** Naming the event types makes the requirement checkable against the workflow file and the existing self-test grep. Alternative: "runs whenever a verdict could change"; rejected as untestable.
- **No new code tests.** The self-test already asserts the trigger lists and the COMMENT, dismissed, and deleted cases; the tasks verify those still pass instead of adding duplicates.

## Risks / Trade-offs

- [This delta modifies `branch-governance`, which exists only inside the unarchived `bootstrap-repo-template` change] → archive `bootstrap-repo-template` first; validate this change again after that archive, before applying or archiving it.
- [The requirement and workflow can drift again] → the existing self-test grep for the trigger lists fails if the workflow changes; a workflow change that alters triggers must update this requirement in the same change.
