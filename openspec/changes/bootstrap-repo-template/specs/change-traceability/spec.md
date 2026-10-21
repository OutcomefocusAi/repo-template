# Spec Delta: change-traceability

## Purpose

Makes every change trace from requirement to issue, branch, commits, pull request, QA verdict, and merge, so anyone can audit why and how code landed.

## ADDED Requirements

### Requirement: One issue per change
The repository SHALL provide issue forms for an OpenSpec change, a docs-only change, and a bug. The change form SHALL collect the change folder path, the Notion Tasks row link, and the tasks checklist. Blank issues SHALL be disabled.

#### Scenario: Opening a change issue
- **WHEN** someone opens a new issue
- **THEN** they choose a form, and the OpenSpec change form requires the change folder path

#### Scenario: Blank issue
- **WHEN** someone tries to open an issue without a form
- **THEN** the option is not offered

### Requirement: Branch and commit naming
`AGENTS.md` SHALL require one branch per issue named `<issue#>-<change-name>` and Conventional Commits that reference the issue on every commit, for example `feat: add log export (#12)`.

#### Scenario: Commit without issue reference
- **WHEN** a pull request from a human or agent branch contains a commit whose subject is not a Conventional Commit ending in an issue reference such as `(#12)`
- **THEN** the CI traceability check fails and names the commit

#### Scenario: Automation pull requests
- **WHEN** the pull request comes from Dependabot or from the release-please branch
- **THEN** the issue-reference part of the check is skipped and the Conventional Commit format is still checked

### Requirement: Pull request template carries traceability fields
The pull request template SHALL include `Closes #`, the change folder link, the Notion row link, a requirement-to-test map, an evidence checklist for lint, typecheck, test, coverage, and build, and a QA verdict section.

#### Scenario: New pull request
- **WHEN** someone opens a pull request
- **THEN** its body starts from the template with every field above

### Requirement: QA verdict recorded on the pull request
The independent QA verdict SHALL be a pull request review of type COMMENT or a pull request comment whose first line is `Independent QA by <reviewer>: <verdict>` with verdict `SHIP`, `SHIP-WITH-FIXES`, or `NO-SHIP`, followed by the full head SHA tested and the evidence. A new verdict SHALL be posted for each new head rather than editing an earlier one.

#### Scenario: Verdict format
- **WHEN** QA finishes reviewing a pull request
- **THEN** the verdict review or comment has a first line that matches the format and a body that names the full head SHA

### Requirement: QA gate orders verdicts by creation time
The `qa-gate` check SHALL consider only comments and reviews from allowlisted accounts, ordered by creation time (a review's submission time), never by edit time, and SHALL take the newest valid verdict for the head.

#### Scenario: Older SHIP edited after a NO-SHIP
- **WHEN** a SHIP comment created before a NO-SHIP comment is edited after it
- **THEN** `qa-gate` fails

### Requirement: QA gate fails closed on later verdict-like lines
The `qa-gate` check SHALL fail when any allowlisted comment or review at the same time as the newest valid verdict or later has a first line that contains "Independent QA by", in any letter case, but is not a valid verdict for the head.

#### Scenario: Later malformed verdict line
- **WHEN** a SHIP for the head is followed by an allowlisted first line containing "independent qa by" that does not match the format, names a short or different SHA, or uses another spelling
- **THEN** `qa-gate` fails

### Requirement: QA gate treats same-second ties as blocking
The `qa-gate` check SHALL fail a SHIP when another verdict for the head that is not SHIP, or a malformed verdict-like line, has the same creation time.

#### Scenario: Same-second tie
- **WHEN** a SHIP and a NO-SHIP or malformed verdict line for the head have the same creation time
- **THEN** `qa-gate` fails

### Requirement: QA gate review handling
The `qa-gate` check SHALL count submitted reviews of type COMMENT (and other submitted states) like comments, SHALL drop dismissed reviews, and SHALL ignore pending reviews and any review without a submission time.

#### Scenario: COMMENT review verdict
- **WHEN** an allowlisted account submits a COMMENT review whose first line is a SHIP verdict naming the head SHA
- **THEN** `qa-gate` passes

#### Scenario: Dismissed review
- **WHEN** the only SHIP verdict is a review that was later dismissed
- **THEN** `qa-gate` fails

#### Scenario: Pending review
- **WHEN** a SHIP verdict exists only in a pending review, or in a review with no submission time
- **THEN** `qa-gate` fails as if no verdict were posted

### Requirement: Release pull request auto-pass is limited
The `qa-gate` check SHALL pass a pull request without a verdict only when its head branch starts with `release-please--`, its head repository is this repository, its author is `github-actions[bot]`, and every changed file is `CHANGELOG.md`, `version.txt`, or `.release-please-manifest.json`.

#### Scenario: Branch named like a release from a fork or an agent
- **WHEN** a pull request from a fork, or from an agent account in this repository, uses a `release-please--` branch name
- **THEN** `qa-gate` requires a verdict like any other pull request

#### Scenario: Genuine release pull request
- **WHEN** release-please opens its pull request from this repository touching only release files
- **THEN** `qa-gate` passes without a verdict
