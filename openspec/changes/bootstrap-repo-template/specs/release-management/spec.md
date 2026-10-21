# Spec Delta: release-management

## Purpose

Turns Conventional Commits on `main` into a maintained changelog and versioned release tags without hand edits, for the template and every derived repository.

## ADDED Requirements

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
Only the release job SHALL hold `contents: write` and `pull-requests: write`; every other job keeps `contents: read`.

#### Scenario: Permission audit
- **WHEN** a reviewer reads the workflows
- **THEN** write permissions appear only on the release job
