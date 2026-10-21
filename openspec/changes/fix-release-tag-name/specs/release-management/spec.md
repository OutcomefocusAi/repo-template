## MODIFIED Requirements

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
