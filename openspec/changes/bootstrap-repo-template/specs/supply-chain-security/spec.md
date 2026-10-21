# Spec Delta: supply-chain-security

## Purpose

Keeps secrets out of the repository and keeps third-party code pinned, current, and licensed acceptably, from the first commit of every derived repository.

## ADDED Requirements

### Requirement: Secrets are scanned before commit
The repository SHALL ship a plain git pre-commit hook in `.githooks/` that runs gitleaks on staged changes with redacted output and blocks the commit when a secret is found. README SHALL give the one command that enables it.

#### Scenario: Staged secret
- **WHEN** a developer with the hook enabled stages a file containing a credential that gitleaks detects
- **THEN** the commit is refused and the finding is shown with the value redacted

#### Scenario: gitleaks missing
- **WHEN** the hook runs on a machine without gitleaks
- **THEN** the commit is refused with a message naming the pinned version to install

### Requirement: Secrets are scanned in CI
CI SHALL run the gitleaks binary at a pinned version, verified against the release checksum, over the commits under test, and fail on any finding. CI SHALL NOT use an action that requires accepting a separate license or obtaining a license key.

#### Scenario: Secret pushed without the hook
- **WHEN** a pull request contains a commit with a detectable secret
- **THEN** CI fails

#### Scenario: Tampered download
- **WHEN** the downloaded gitleaks archive does not match the pinned checksum
- **THEN** CI fails before running it

### Requirement: Dependabot keeps actions current
`.github/dependabot.yml` SHALL enable weekly version updates for the `github-actions` ecosystem and SHALL contain commented slots for the stack ecosystems a project adds.

#### Scenario: Action update available
- **WHEN** a pinned action has a newer release
- **THEN** Dependabot opens a pull request that updates the SHA and its version comment

### Requirement: Environment variables are documented, never committed
The repository SHALL contain `.env.example` with placeholder values only, and `.gitignore` SHALL exclude `.env` and `.env.*` except `.env.example`.

#### Scenario: Local env file
- **WHEN** a developer creates `.env.local`
- **THEN** git does not track it

### Requirement: Security policy exists
`SECURITY.md` SHALL say how to report a vulnerability privately to the owner without opening a public issue, and what to do when a secret is exposed (revoke and rotate first, then clean history).

#### Scenario: Leaked key
- **WHEN** someone finds a committed credential
- **THEN** `SECURITY.md` tells them to revoke and rotate it before anything else

### Requirement: Third-party tools are pinned and license-checked
Every third-party tool the template uses SHALL be pinned to an exact version or commit SHA, and its license SHALL be recorded in design.md or `TEMPLATE_SOURCE.md`.

#### Scenario: Reviewer audits tools
- **WHEN** a reviewer lists the tools in workflows and hooks
- **THEN** each has an exact pin and a recorded license
