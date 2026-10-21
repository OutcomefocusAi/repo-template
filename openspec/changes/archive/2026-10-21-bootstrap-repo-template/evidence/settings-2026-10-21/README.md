# Repository settings applied 2026-10-21

Applied by Principal Engineer at 1:25 PM MST (America/Phoenix) with Woody's approval recorded in `proposal.md` (option selected on Chief of Staff's card, 1:25 PM MST). Every file is the raw GitHub REST API response, read with `gh api` just before (`*-before.json`) and just after (`*-after.json`) the change.

| Setting | Files | Before | After |
| --- | --- | --- | --- |
| Ruleset `protect-main` (id 25587598): `qa-gate` required check pinned to the GitHub Actions app | `ruleset-before.json`, `ruleset-put.json` (request body), `ruleset-after.json` | `{"context":"qa-gate"}` | `{"context":"qa-gate","integration_id":15368}` |
| Same ruleset: `require_extra_approval_for_unattributed_changes` | same | `true` | `false` |
| Actions: `can_approve_pull_request_reviews` | `actions-workflow-before.json`, `actions-workflow-attempt.json`, `actions-workflow-after.json` | `false` | `false` (not changed: HTTP 409, the organization does not allow it; an org owner must turn it on first) |
| Private vulnerability reporting | `pvr-before.json`, `pvr-after.json` | `{"enabled":false}` | `{"enabled":true}` |
| Secret scanning and push protection | `security-and-analysis-before.json`, `security-and-analysis-after.json` | both `disabled` | both `enabled` |

Every other ruleset field (target, enforcement `active`, `~DEFAULT_BRANCH`, empty bypass list, the other rules and checks) is unchanged; `diff` of the `rules` arrays shows only the two lines above.
