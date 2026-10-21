# Spec Delta: continuous-integration

## Purpose

Runs the same quality and safety checks on every pull request and every push to `main`, hardened against supply-chain and token abuse, with stack-specific steps left as slots a project fills.

## ADDED Requirements

### Requirement: CI runs on every pull request and push to main
A CI workflow SHALL run on `pull_request` and on `push` to `main`. It SHALL NOT use `pull_request_target`.

#### Scenario: Pull request opened
- **WHEN** a pull request targets `main`
- **THEN** the CI workflow runs against its head

#### Scenario: Forbidden trigger
- **WHEN** a reviewer searches the workflows for `pull_request_target`
- **THEN** there are no matches

### Requirement: Workflows are hardened
Every workflow SHALL pin each third-party action to a full commit SHA with the version in a comment, set top-level `permissions` to `contents: read` and raise permissions only per job where needed, set `concurrency` that cancels superseded runs on pull requests, and set `timeout-minutes` on every job.

#### Scenario: Unpinned action
- **WHEN** a workflow references an action by tag or branch instead of a 40-character SHA
- **THEN** the template checks job fails and names the line

#### Scenario: Job without timeout
- **WHEN** a job has no `timeout-minutes`
- **THEN** the template checks job fails and names the job

### Requirement: Template checks always run
The CI workflow SHALL run template checks on every run: `openspec validate --all --strict`, an em-dash check over hand-written files, a gitleaks scan of the commits under test, a workflow lint, and the Conventional Commit and issue-reference check on pull requests.

#### Scenario: Em dash in a hand-written file
- **WHEN** a hand-written tracked file contains U+2014
- **THEN** the em-dash check fails and prints file and line

#### Scenario: Generated and vendored files
- **WHEN** an OpenSpec-generated skill, a vendored Ponytail file, a LICENSE file, or the release-please CHANGELOG contains U+2014
- **THEN** the em-dash check ignores it

#### Scenario: OpenSpec invalid
- **WHEN** any change or spec fails `openspec validate --all --strict`
- **THEN** CI fails

### Requirement: Stack steps are marked slots
The CI workflow SHALL contain lint, typecheck, test, coverage gate, and build steps as clearly marked slots. The first project proposal in a derived repository SHALL fill every slot with the stack's real commands.

#### Scenario: Slot markers
- **WHEN** a reviewer reads the CI workflow in the template
- **THEN** each of the five steps carries a `SLOT` marker naming what the project must supply

### Requirement: Unfilled slots fail outside the template
When CI runs in any repository other than `OutcomefocusAi/repo-template`, a slot still marked unfilled SHALL fail the run. In the template repository itself an unfilled slot SHALL pass with a visible warning.

#### Scenario: Derived repository with unfilled slot
- **WHEN** CI runs in a repository created from the template and a slot is still unfilled
- **THEN** that step fails with a message pointing to the first project proposal

#### Scenario: Template repository
- **WHEN** CI runs in `OutcomefocusAi/repo-template`
- **THEN** unfilled slots pass and emit a warning annotation

### Requirement: Coverage gate enforces the testing bar
The coverage slot SHALL fail CI when line coverage on new code is below 80%, and on paths a project marks as money or critical is below 90%.

#### Scenario: Coverage below bar
- **WHEN** a filled coverage step measures 79% line coverage on new code
- **THEN** CI fails

### Requirement: CI stays within the free minutes budget
CI jobs SHALL run on standard Linux GitHub-hosted runners only, and no workflow SHALL upload artifacts unless a project proposal adds one with a retention period.

#### Scenario: Runner choice
- **WHEN** a reviewer reads `runs-on` across the workflows
- **THEN** every job uses a standard Linux runner label
