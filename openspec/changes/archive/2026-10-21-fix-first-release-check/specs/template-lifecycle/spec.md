## MODIFIED Requirements

### Requirement: README explains starting a new repository
README SHALL give the exact steps to create a private repository from the template with `gh repo create --template`, set the owner's commit identity, enable the pre-commit hook, reset the inherited release state (`.release-please-manifest.json` and `version.txt` to `0.0.0`, no `CHANGELOG.md`), record the template version, and open the first project proposal that fills the CI slots.

#### Scenario: Following the README
- **WHEN** an agent follows the README steps for a new project
- **THEN** it ends with a private repository, the hook enabled, `TEMPLATE_SOURCE.md` filled, and a first issue for the project proposal

#### Scenario: First release of a derived repository
- **WHEN** an agent follows the README steps on a template release that already has its own `CHANGELOG.md` and version
- **THEN** the derived repository's manifest and `version.txt` read `0.0.0`, it has no `CHANGELOG.md`, and its first release pull request proposes `0.1.0`
