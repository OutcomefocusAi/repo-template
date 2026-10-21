# Spec Delta: branch-governance

## MODIFIED Requirements

### Requirement: QA gate check
A `qa-gate` check SHALL run when a pull request is opened, synchronized, or reopened, when a pull request comment is created, edited, or deleted, and when a review is submitted, edited, or dismissed. It SHALL pass only when the newest verdict from an allowlisted author, given as a pull request comment or a submitted review whose first line is `Independent QA by <reviewer>: SHIP`, names the current head SHA.

#### Scenario: No verdict yet
- **WHEN** a pull request has no QA verdict comment or review
- **THEN** `qa-gate` fails with a message saying QA has not shipped this head

#### Scenario: Verdict for an older head
- **WHEN** the only SHIP verdict names a SHA that is no longer the head
- **THEN** `qa-gate` fails

#### Scenario: Verdict from a non-allowlisted account
- **WHEN** an account not on the allowlist posts a SHIP verdict for the head SHA as a comment or review
- **THEN** `qa-gate` ignores it

#### Scenario: Release pull request
- **WHEN** a release-please pull request changes only `CHANGELOG.md`, `version.txt`, and `.release-please-manifest.json`
- **THEN** `qa-gate` passes without a verdict comment or review

#### Scenario: SHIP-WITH-FIXES or NO-SHIP
- **WHEN** the latest verdict for the head is `SHIP-WITH-FIXES` or `NO-SHIP`
- **THEN** `qa-gate` fails

#### Scenario: Verdict as a COMMENT review
- **WHEN** an allowlisted author submits a review of type COMMENT whose first line is a SHIP verdict naming the head SHA
- **THEN** `qa-gate` runs on the submitted review and passes

#### Scenario: Verdict deleted or dismissed
- **WHEN** the comment or review holding the only SHIP verdict for the head is deleted or dismissed
- **THEN** `qa-gate` runs again and fails
