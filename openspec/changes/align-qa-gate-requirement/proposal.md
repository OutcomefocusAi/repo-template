# Proposal: align-qa-gate-requirement

Tracking issue: #6. Branch: `6-align-qa-gate-requirement`. Not docs-only: it changes the text of a spec requirement, so it goes through OpenSpec and waits for Woody's approval before apply.

## Approval

| What | Words or selected option text | How given, where and when |
| --- | --- | --- |
| Approve this proposal (together with the close-out of `bootstrap-repo-template`, issue #7) | Option selected by Woody: "Yes to both: close out the repo-template build with 11.2 deferred (including the 0.1.0 version fix), and approve the #6 proposal." (answering "Approve the close-out and the spec fix?") | Option selected on Chief of Staff's card in Woody's chat with Chief of Staff, 2026-10-21 1:45 PM MST; option text by Chief of Staff; relayed verbatim to Principal Engineer. Recorded here before apply |

## Why

The branch-governance requirement "QA gate check" still says `qa-gate` runs "when comments are added" and passes on "a pull request comment". Since `bootstrap-repo-template`, the `qa-gate` workflow also runs when a comment is edited or deleted and when a review is submitted, edited, or dismissed, and it counts submitted reviews of type COMMENT as verdicts. The change-traceability requirements already describe that behavior, so the two capabilities disagree. Principal QA raised it in issue #6 when shipping PR #2 at `645d98d`.

## What Changes

- Reword the branch-governance requirement "QA gate check" so it names every trigger (pull request opened, synchronize, reopened; comment created, edited, deleted; review submitted, edited, dismissed) and says a verdict may be a pull request comment or a submitted review.
- Adjust its scenarios to say "comment or review" where they said "comment", and add two scenarios: a verdict posted as a COMMENT review, and a re-evaluation after a verdict is deleted or dismissed.
- No workflow, script, or setting changes: the code already behaves this way (`.github/workflows/qa-gate.yml` on `main` at `56975b7`), and the self-test already covers it.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `branch-governance`: the "QA gate check" requirement now lists all triggers and accepts a pull request comment or submitted review as the verdict.

## Impact

- `openspec/changes/align-qa-gate-requirement/specs/branch-governance/spec.md` (delta), and after archive `openspec/specs/branch-governance/spec.md`.
- Ordering: `bootstrap-repo-template` must be archived first, because it creates `openspec/specs/branch-governance/spec.md`, which this change modifies.
- No code, CI, dependency, or setting change. No effect on derived repositories until they pull the template's specs.
