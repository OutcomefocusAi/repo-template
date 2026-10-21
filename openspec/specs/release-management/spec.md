# release-management Specification

## Purpose

Turns Conventional Commits on `main` into a maintained changelog and versioned release tags without hand edits, for the template and every derived repository.

## Requirements

### Requirement: Release pull request from Conventional Commits
A release workflow SHALL run on push to `main` and keep one open release pull request that updates `CHANGELOG.md` and the version from Conventional Commits since the last release.

#### Scenario: Feature merged
- **WHEN** a `feat:` commit lands on `main`
- **THEN** the release pull request proposes a minor version bump with the commit listed in the changelog

### Requirement: Tags only on merging the release pull request
A version tag and GitHub release SHALL be created only when the release pull request is merged. Nothing SHALL be published to a package registry or deployed by this workflow.

#### Scenario: Release pull request merged
- **WHEN** Woody merges the release pull request
- **THEN** a tag `vX.Y.Z` and a GitHub release are created for that commit and nothing is deployed

### Requirement: Release workflow has least privilege
Every workflow SHALL set top-level permissions to `contents: read`. Write permissions SHALL appear only on two jobs: the release job, which holds `contents: write`, `pull-requests: write`, and `issues: write` (release-please labels its pull request), and the `qa-gate` job, which holds `statuses: write` and nothing else that writes, so it can set the `qa-gate` commit status (design D3). Every other job keeps read-only permissions.

#### Scenario: Permission audit
- **WHEN** a reviewer reads the workflows
- **THEN** write permissions appear only on the release job and, limited to `statuses: write`, on the `qa-gate` job
