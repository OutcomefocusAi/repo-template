# Spec Delta: branch-governance

## Purpose

Keeps `main` limited to reviewed pull requests that Principal QA shipped and Woody approved, using what the current GitHub plan offers.

## ADDED Requirements

### Requirement: Merge rule in AGENTS.md
`AGENTS.md` SHALL forbid committing or pushing directly to `main` and SHALL allow merging a pull request only after CI passes, a SHIP verdict for the current head SHA is on it, and Woody has approved where required.

#### Scenario: Agent asked to push to main
- **WHEN** an agent has a change ready
- **THEN** `AGENTS.md` directs it to a branch and pull request, never to `main`

### Requirement: QA gate check
A `qa-gate` check SHALL run on pull requests and when comments are added, and SHALL pass only when a pull request comment whose first line is `Independent QA by <reviewer>: SHIP` names the current head SHA.

#### Scenario: No verdict yet
- **WHEN** a pull request has no QA verdict comment
- **THEN** `qa-gate` fails with a message saying QA has not shipped this head

#### Scenario: Verdict for an older head
- **WHEN** the only SHIP verdict names a SHA that is no longer the head
- **THEN** `qa-gate` fails

#### Scenario: SHIP WITH FIXES or NO-SHIP
- **WHEN** the latest verdict for the head is SHIP WITH FIXES or NO-SHIP
- **THEN** `qa-gate` fails

### Requirement: Direct pushes to main are flagged
A `main-guard` check SHALL run on every push to `main` and SHALL fail, naming the commit, when a pushed commit is not part of a merged pull request, unless it is a release-please or Dependabot merge.

#### Scenario: Direct push
- **WHEN** a commit is pushed to `main` without a pull request
- **THEN** `main-guard` fails and the commit shows a red status on `main`

### Requirement: Enforcement level is stated honestly
README and `AGENTS.md` SHALL state whether merge rules are enforced by GitHub or only flagged, matching the plan and visibility chosen in Decision 1.

#### Scenario: Private repository on GitHub Free
- **WHEN** the template is private on GitHub Free for organizations
- **THEN** README says the checks flag violations but cannot block a merge or push
