# supply-chain-security Specification

## Purpose

Keeps secrets out of the repository and keeps third-party code pinned, current, and licensed acceptably, from the first commit of every derived repository.

## Requirements

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
Every third-party tool the template uses SHALL be pinned to an exact version or commit SHA, and its license SHALL be recorded in design.md or `TEMPLATE_SOURCE.md`. A tool installed from npm without a lockfile SHALL also be installed with a recorded `--before=<UTC timestamp>` cutoff so its transitive dependencies resolve only to versions published before that time.

#### Scenario: Reviewer audits tools
- **WHEN** a reviewer lists the tools in workflows and hooks
- **THEN** each has an exact pin and a recorded license

#### Scenario: Node.js minimum recorded
- **WHEN** a reviewer reads the `@fission-ai/openspec` Tool pins row in `TEMPLATE_SOURCE.md`
- **THEN** it states the pinned version's `engines.node` minimum (Node.js 22.20.0 or newer for 2.1.1), and the Node.js version CI installs meets it

#### Scenario: Upstream publishes a new transitive dependency
- **WHEN** a package in the OpenSpec CLI's dependency tree publishes a new version after the recorded cutoff
- **THEN** the CI install selects only versions published before the cutoff and does not request the new version

#### Scenario: Cutoff missing or malformed
- **WHEN** an `@fission-ai/openspec@<version>` install line in `.github/workflows/*.yml` or `*.yaml` is not exactly `npm install --global --no-fund --no-audit --before=<cutoff> @fission-ai/openspec@<version>` (no cutoff, a second cutoff in either form, `--enjoy-by`, `--min-release-age-exclude`, or anything after the package such as `||`, `;` or `#`), or the cutoff is not a real UTC time written `YYYY-MM-DDTHH:MM:SSZ` (for example `2026-13-45T00:00:00Z`, which npm would ignore with only a warning)
- **THEN** CI fails with an annotation naming the workflow file and line

#### Scenario: Install line spread over several lines
- **WHEN** the line before an OpenSpec install line ends in a `\` continuation, or the install line is not inside a literal `run: |` block (for example a folded `run: >` block, where the next line joins the command)
- **THEN** CI fails with an annotation naming the workflow file and the install line

#### Scenario: Cutoff that npm ignores or that excludes nothing
- **WHEN** the cutoff is earlier than 2020-01-01T00:00:00Z (npm ignores year 0000 with only a warning) or later than the time the check runs (a future cutoff excludes nothing)
- **THEN** CI fails with an annotation naming the workflow file and line

#### Scenario: Cutoff records disagree
- **WHEN** the Tool pins row for `@fission-ai/openspec` in `TEMPLATE_SOURCE.md` records no `--before=` cutoff, or a different one from a CI install line
- **THEN** CI fails with an annotation naming `TEMPLATE_SOURCE.md` and the row's line

#### Scenario: npm config set through the workflow environment
- **WHEN** a workflow sets any `npm_config_*` or `NPM_CONFIG_*` variable, in any letter case, which could override or exempt the cutoff
- **THEN** CI fails with an annotation naming the workflow file and line

#### Scenario: npm config written by a workflow
- **WHEN** a workflow line mentions `npmrc` or runs `npm config set`, `npm config edit` or `npm set`, which could write a user or global npm config that overrides or exempts the cutoff
- **THEN** CI fails with an annotation naming the workflow file and line

#### Scenario: Cutoff earlier than the pinned version
- **WHEN** the cutoff is earlier than the pinned OpenSpec version's publish time
- **THEN** the install step fails and no older OpenSpec version is installed
