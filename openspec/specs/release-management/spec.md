# release-management Specification

## Purpose

Turns Conventional Commits on `main` into a maintained changelog and versioned release tags without hand edits, for the template and every derived repository.

## Requirements

### Requirement: Release pull request from Conventional Commits
A release workflow SHALL run on push to `main` and keep one open release pull request that updates `CHANGELOG.md` and the version from Conventional Commits since the last release.

#### Scenario: Feature merged
- **WHEN** a `feat:` commit lands on `main`
- **THEN** the release pull request proposes a minor version bump with the commit listed in the changelog

#### Scenario: First release
- **WHEN** no release has been made yet and `.release-please-manifest.json` and `version.txt` read `0.0.0`
- **THEN** the release pull request proposes version `0.1.0`, and the template self-test passes

#### Scenario: Versions consistent after a release
- **WHEN** a release pull request is open, or has been merged, with version `X.Y.Z`
- **THEN** `.release-please-manifest.json` and `version.txt` both read `X.Y.Z`, the newest `CHANGELOG.md` heading is `X.Y.Z`, and the template self-test passes

#### Scenario: Version files disagree
- **WHEN** `.release-please-manifest.json` and `version.txt` hold different versions, or the newest `CHANGELOG.md` heading does not match them
- **THEN** the template self-test fails and names the values it found

#### Scenario: Breaking change before 1.0.0
- **WHEN** the current version is below `1.0.0` and a breaking-change commit lands on `main`
- **THEN** the release pull request proposes a minor version bump, not `1.0.0`

#### Scenario: Deliberate 1.0.0
- **WHEN** a commit on `main` carries the footer `Release-As: 1.0.0`
- **THEN** the release pull request proposes `1.0.0`

### Requirement: Tags only on merging the release pull request
A version tag and GitHub release SHALL be created only when the release pull request is merged. The tag and the GitHub release name SHALL both be `v` followed by the version (`vX.Y.Z`), with no component or package-name prefix. Nothing SHALL be published to a package registry or deployed by this workflow.

#### Scenario: Release pull request merged
- **WHEN** Woody merges the release pull request
- **THEN** a tag `vX.Y.Z` and a GitHub release are created for that commit and nothing is deployed

#### Scenario: First release tag
- **WHEN** Woody merges the first release pull request, which proposes version `0.1.0`
- **THEN** the tag is `v0.1.0`, not `repo-template-v0.1.0` or any other prefixed form

#### Scenario: Release name matches the tag
- **WHEN** a GitHub release is created for version `X.Y.Z`
- **THEN** its name is `vX.Y.Z`, the same as its tag

#### Scenario: Component in the tag configured
- **WHEN** `release-please-config.json` does not set `include-component-in-tag` to the JSON boolean `false`
- **THEN** the template self-test fails and names the value it found

### Requirement: Release workflow has least privilege
Every workflow SHALL set top-level permissions to `contents: read`. Write permissions SHALL appear only on two jobs: the release job, which holds `contents: write`, `pull-requests: write`, and `issues: write` (release-please labels its pull request), and the `qa-gate` job, which holds `statuses: write` and nothing else that writes, so it can set the `qa-gate` commit status (design D3). Every other job keeps read-only permissions.

#### Scenario: Permission audit
- **WHEN** a reviewer reads the workflows
- **THEN** write permissions appear only on the release job and, limited to `statuses: write`, on the `qa-gate` job
