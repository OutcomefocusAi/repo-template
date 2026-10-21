## MODIFIED Requirements

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
