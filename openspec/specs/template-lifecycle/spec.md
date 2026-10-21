# template-lifecycle Specification

## Purpose

Defines how the template is published, how a new repository is started from it, how each derived repository records which template version it came from, and how drift from the template is found.

## Requirements

### Requirement: Repository is a public GitHub template
`OutcomefocusAi/repo-template` SHALL be public, marked as a template repository, and have its own history unrelated to openspec-sandbox. It SHALL be made public only after a privacy check of every file, every commit, and every issue and pull request body finds nothing private.

#### Scenario: Template flag
- **WHEN** `gh api repos/OutcomefocusAi/repo-template --jq .is_template` runs
- **THEN** it prints `true`

#### Scenario: Visibility
- **WHEN** `gh api repos/OutcomefocusAi/repo-template --jq .visibility` runs
- **THEN** it prints `public`

#### Scenario: Privacy check before publishing
- **WHEN** the privacy check finds a private item
- **THEN** the repository stays private until the item is removed from history

#### Scenario: Fresh history
- **WHEN** a reviewer runs `git log` on the template
- **THEN** no openspec-sandbox commit appears

### Requirement: README explains starting a new repository
README SHALL give the exact steps to create a private repository from the template with `gh repo create --template`, set the owner's commit identity, enable the pre-commit hook, record the template version, and open the first project proposal that fills the CI slots.

#### Scenario: Following the README
- **WHEN** an agent follows the README steps for a new project
- **THEN** it ends with a private repository, the hook enabled, `TEMPLATE_SOURCE.md` filled, and a first issue for the project proposal

### Requirement: Derived repositories record their template version
Every repository made from the template SHALL keep `TEMPLATE_SOURCE.md` naming the template repository, the release tag, the full commit SHA it was created from, and the date.

#### Scenario: New repository
- **WHEN** a repository is created from the template
- **THEN** its first commit sets `TEMPLATE_SOURCE.md` to the template tag and SHA used

### Requirement: Drift is detectable on demand
The template SHALL ship a drift check that compares a derived repository's template-managed files against a chosen template tag and prints which files differ, without changing anything.

#### Scenario: Template updated
- **WHEN** the drift check runs in a derived repository against a newer template tag
- **THEN** it lists each template-managed file that differs and exits non-zero if any do

#### Scenario: No drift
- **WHEN** the derived repository matches the tag
- **THEN** the check prints that nothing differs and exits zero

### Requirement: Repository hygiene files
The template SHALL include `.editorconfig` (UTF-8, LF line endings, final newline, trimmed trailing whitespace except in Markdown) and `CODEOWNERS` naming `@AgileKnow23` as owner of every path.

#### Scenario: CODEOWNERS valid
- **WHEN** `gh api repos/OutcomefocusAi/repo-template/codeowners/errors` runs
- **THEN** it reports no errors

#### Scenario: Editor settings
- **WHEN** an editor that honors EditorConfig opens a file
- **THEN** it uses UTF-8 and LF endings
