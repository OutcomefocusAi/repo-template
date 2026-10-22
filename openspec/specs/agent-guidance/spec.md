# agent-guidance Specification

## Purpose

Gives every AI agent and tool that opens a repository made from this template one authoritative set of working rules, stored in the repository itself.

## Requirements

### Requirement: AGENTS.md is the single source of repository rules
The repository SHALL contain `AGENTS.md` at its root holding every working rule for agents. Any other instruction file written for the repository, such as `CLAUDE.md`, SHALL only point to `AGENTS.md` and add no rules of its own.

#### Scenario: Claude-based tool opens the repository
- **WHEN** a tool that reads `CLAUDE.md` opens the repository
- **THEN** `CLAUDE.md` contains `@AGENTS.md` and a one-line pointer, and no other rule

#### Scenario: Repo-authored instruction files agree
- **WHEN** a reviewer compares `AGENTS.md` with every other instruction file authored for the repository
- **THEN** no other file states a rule that `AGENTS.md` does not

### Requirement: AGENTS.md carries the sandbox guidance forward
`AGENTS.md` SHALL contain the guidance from openspec-sandbox `AGENTS.md` as merged from PR #1 (or its latest head if not yet merged), with that source commit recorded, adapted only where this proposal says so.

#### Scenario: Source recorded
- **WHEN** a reviewer reads `TEMPLATE_SOURCE.md`
- **THEN** it names the openspec-sandbox commit the `AGENTS.md` text was taken from

#### Scenario: Sections carried over
- **WHEN** a reviewer compares the template `AGENTS.md` with the recorded source
- **THEN** the workflow, Ponytail, order of authority, testing standard, non-negotiables, engineering standards, and writing style sections are present

### Requirement: Docs-only changes skip OpenSpec but keep traceability
`AGENTS.md` SHALL state Woody's docs-only waiver with its source, define docs-only as in the openspec-sandbox source (edits to documentation, including `AGENTS.md`, that add no capability and change no code, configuration, dependencies, CI, or runtime behavior), and require that docs-only changes still have an issue, an `<issue#>-<change-name>` branch, Conventional Commits referencing the issue, a pull request with `Closes #N`, QA review, and Woody's OK before merge.

#### Scenario: Docs-only change
- **WHEN** a change touches only documentation and alters no capability, code, configuration, or behavior
- **THEN** `AGENTS.md` lets it skip the OpenSpec proposal and still requires every traceability step

#### Scenario: Unsure whether docs-only
- **WHEN** an agent cannot tell whether a change is docs-only
- **THEN** `AGENTS.md` tells it to treat the change as not docs-only

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

### Requirement: AGENTS.md states stack defaults
`AGENTS.md` SHALL list the default stacks (strict TypeScript for web, apps, and APIs; Python 3.12+ with type hints, uv, ruff, pytest for data, AI, and automation; SQL/Postgres for data; Bash only for glue) and require any deviation to be justified in the proposal.

#### Scenario: Project picks a non-default stack
- **WHEN** a first project proposal chooses a language outside the defaults
- **THEN** `AGENTS.md` requires the proposal to justify it

### Requirement: AGENTS.md states testing and security bars
`AGENTS.md` SHALL require unit tests on business logic, at least 80% line coverage on new code, at least 90% on money and critical paths, integration tests at boundaries, Playwright E2E on critical journeys in UI projects, and a failing test first for every bug. It SHALL state the security rules.

#### Scenario: Coverage bar
- **WHEN** a reviewer reads the testing section
- **THEN** it states the 80% and 90% line coverage bars and the E2E rule

#### Scenario: Security rules
- **WHEN** a reviewer reads the security rules
- **THEN** they require secrets only in environment variables or a secret store, input validation, OWASP Top 10 awareness, dependency audits, and pinned dependencies

### Requirement: Ponytail skills are vendored at a pinned commit
The repository SHALL vendor the ponytail, ponytail-review, and ponytail-audit skills under `.agents/skills/` byte for byte from the pinned upstream commit, each with its LICENSE and a SOURCE.md naming the commit.

#### Scenario: Vendored copies match
- **WHEN** a reviewer compares SHA-256 values of the vendored SKILL.md files with the openspec-sandbox copies
- **THEN** they match

### Requirement: Skills live in .agents/skills
OpenSpec-generated skills SHALL live in `.agents/skills/openspec-*/` as produced by `openspec init --tools agents` at the pinned OpenSpec version, and `AGENTS.md` SHALL name the skill for each workflow step that has one.

#### Scenario: Skills present
- **WHEN** a reviewer lists `.agents/skills/`
- **THEN** it contains the six OpenSpec skills (propose, explore, apply-change, update-change, sync-specs, archive-change) unmodified from generation
