# branch-governance Specification

## Purpose

Keeps `main` limited to reviewed pull requests that Principal QA shipped and Woody approved, with enforced protection where the plan and visibility allow and flagged violations elsewhere.

## Requirements

### Requirement: Merge rule in AGENTS.md
`AGENTS.md` SHALL forbid committing or pushing directly to `main` and SHALL allow merging a pull request only after CI passes, a SHIP verdict for the current head SHA is on it, and Woody has approved where required.

#### Scenario: Agent asked to push to main
- **WHEN** an agent has a change ready
- **THEN** `AGENTS.md` directs it to a branch and pull request, never to `main`

### Requirement: Ruleset protects main on the public template
`main` in `OutcomefocusAi/repo-template` SHALL have an active ruleset that requires a pull request (zero approving reviews, squash merge only), requires the `template-checks`, `project`, and `qa-gate` checks, requires linear history, blocks force pushes and deletion, and has an empty bypass list.

#### Scenario: Ruleset read back
- **WHEN** `gh api repos/OutcomefocusAi/repo-template/rulesets/<id>` runs
- **THEN** it shows enforcement `active`, the rules above, and `bypass_actors` empty

#### Scenario: Direct push attempt
- **WHEN** anyone, including an org admin, pushes directly to `main`
- **THEN** GitHub rejects the push

### Requirement: QA gate check
A `qa-gate` check SHALL run on pull requests and when comments are added, and SHALL pass only when a pull request comment from an allowlisted author, whose first line is `Independent QA by <reviewer>: SHIP`, names the current head SHA.

#### Scenario: No verdict yet
- **WHEN** a pull request has no QA verdict comment
- **THEN** `qa-gate` fails with a message saying QA has not shipped this head

#### Scenario: Verdict for an older head
- **WHEN** the only SHIP verdict names a SHA that is no longer the head
- **THEN** `qa-gate` fails

#### Scenario: Verdict from a non-allowlisted account
- **WHEN** an account not on the allowlist comments a SHIP verdict for the head SHA
- **THEN** `qa-gate` ignores it

#### Scenario: Release pull request
- **WHEN** a release-please pull request changes only `CHANGELOG.md`, `version.txt`, and `.release-please-manifest.json`
- **THEN** `qa-gate` passes without a verdict comment

#### Scenario: SHIP-WITH-FIXES or NO-SHIP
- **WHEN** the latest verdict for the head is `SHIP-WITH-FIXES` or `NO-SHIP`
- **THEN** `qa-gate` fails

### Requirement: Direct pushes to main are flagged
A `main-guard` check SHALL run on every push to `main` and SHALL fail, naming the commit, when a pushed commit is not part of a merged pull request, unless it is a release-please or Dependabot merge.

#### Scenario: Direct push
- **WHEN** a commit is pushed to `main` without a pull request
- **THEN** `main-guard` fails and the commit shows a red status on `main`

### Requirement: Enforcement level is stated honestly
README and `AGENTS.md` SHALL state whether merge rules are enforced by GitHub or only flagged, for public repositories (ruleset) and for private repositories on GitHub Free (flag-only).

#### Scenario: Public template
- **WHEN** a reader checks README on the public template
- **THEN** it says the ruleset blocks direct pushes and merges without the required checks

#### Scenario: Private derived repository on GitHub Free
- **WHEN** a repository created from the template is private on GitHub Free for organizations
- **THEN** README says rulesets are unavailable there and the checks only flag violations
