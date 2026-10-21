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
