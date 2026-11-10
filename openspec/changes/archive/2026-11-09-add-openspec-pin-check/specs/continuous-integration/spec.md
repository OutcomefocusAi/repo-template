## MODIFIED Requirements

### Requirement: Template checks always run
The CI workflow SHALL run template checks on every run: `openspec validate --all --strict`, an em-dash check over hand-written files, a check that every record of the pinned OpenSpec version names the same exact version, a check that the vendored Ponytail skills' pin records agree and match the vendored files, a gitleaks scan of the commits under test, a workflow lint, and the Conventional Commit and issue-reference check on pull requests.

#### Scenario: Em dash in a hand-written file
- **WHEN** a hand-written tracked file contains U+2014
- **THEN** the em-dash check fails and prints file and line

#### Scenario: Generated and vendored files
- **WHEN** an OpenSpec-generated skill, a vendored Ponytail file, a LICENSE file, or the release-please CHANGELOG contains U+2014
- **THEN** the em-dash check ignores it

#### Scenario: OpenSpec invalid
- **WHEN** any change or spec fails `openspec validate --all --strict`
- **THEN** CI fails

#### Scenario: OpenSpec version records disagree
- **WHEN** the `generatedBy` value in any `.agents/skills/openspec-*/SKILL.md`, the `@fission-ai/openspec` install pin in `.github/workflows/ci.yml`, or the OpenSpec row in the Sources or Tool pins table of `TEMPLATE_SOURCE.md` names a different version from the others
- **THEN** CI fails and prints the file, line and version of each record

#### Scenario: OpenSpec version record missing or not exact
- **WHEN** one of those records is missing, appears more than once, or is not an exact `MAJOR.MINOR.PATCH` version (for example `^1.17.0` or `latest`)
- **THEN** CI fails and names the file of that record

#### Scenario: Ponytail pin records disagree
- **WHEN** the pinned commit in any `.agents/skills/ponytail*/SOURCE.md` (its "Pinned commit" value or the commit in its "File at that commit" link), or its `git describe` string, differs from the commit or `git describe` string in the Ponytail row of the Sources table of `TEMPLATE_SOURCE.md`, or any of those records is missing or is not a full 40-character commit SHA
- **THEN** CI fails and names the file and line of each such record

#### Scenario: Vendored Ponytail file does not match its recorded fingerprint
- **WHEN** the SHA-256 of a vendored Ponytail `SKILL.md` or `LICENSE` differs from the value recorded in that folder's `SOURCE.md`
- **THEN** CI fails and names the file with both values
