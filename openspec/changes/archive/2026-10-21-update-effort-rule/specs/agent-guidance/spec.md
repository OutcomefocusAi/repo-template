## RENAMED Requirements

- FROM: `### Requirement: AGENTS.md states the maximum effort rule`
- TO: `### Requirement: AGENTS.md states the effort rule`

## MODIFIED Requirements

### Requirement: AGENTS.md states the effort rule
`AGENTS.md` SHALL require the highest effort or reasoning level available for code, features, releases, design, debugging, testing, review, and verification work, including independent QA of any change, and for any delegated worker doing that work. It SHALL allow normal effort for docs-only changes, OpenSpec archive work, and routine CI or status checks, SHALL require the highest level when unsure, and SHALL leave every approval gate unchanged.

#### Scenario: Agent delegates work
- **WHEN** an agent hands code, feature, release, design, debugging, testing, review, or verification work to a background worker
- **THEN** `AGENTS.md` requires it to choose the highest effort setting offered

#### Scenario: Docs-only, archive, or routine CI work
- **WHEN** an agent does, or delegates, a docs-only change, an OpenSpec archive, or a routine CI or status check
- **THEN** `AGENTS.md` allows normal effort for that work, and independent QA of the change still uses the highest level

#### Scenario: Unsure which effort applies
- **WHEN** an agent cannot tell whether work falls under the normal-effort list
- **THEN** `AGENTS.md` requires the highest effort level

#### Scenario: Approval gates unchanged
- **WHEN** a reviewer compares the approval, QA, and merge rules in `AGENTS.md` before and after this rule changes
- **THEN** no gate is removed or weakened, whatever effort level the work used
