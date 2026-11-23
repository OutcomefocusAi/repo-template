## MODIFIED Requirements

### Requirement: Template checks always run
The CI workflow SHALL run template checks on every run: `openspec validate --all --strict`, an em-dash check over hand-written files, a check that all OpenSpec version records name one exact version, a check that the vendored Ponytail pin records agree and match the files, a check that the generated OpenSpec skills match what the pinned version generates, a gitleaks scan of the commits under test, a workflow lint, and the Conventional Commit and issue-reference check on pull requests.

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
- **WHEN** a `generatedBy` value present in any `.agents/skills/openspec-*/SKILL.md`, an `@fission-ai/openspec` install pin in `.github/workflows/*.yml` or `*.yaml`, or the OpenSpec row in the Sources or Tool pins table of `TEMPLATE_SOURCE.md` names a different version from the others
- **THEN** CI fails and prints the file, line and version of each record

#### Scenario: Generated skills carry no version stamp
- **WHEN** the pinned OpenSpec version writes no `generatedBy` line (2.1.x) and none of the six generated skills carries one
- **THEN** the pin check passes on the install pin and the two `TEMPLATE_SOURCE.md` rows, and the generated-skills check is what proves the skills come from that version

#### Scenario: Stamps on only some generated skills
- **WHEN** some `.agents/skills/openspec-*/SKILL.md` files carry a `generatedBy` line and others do not, even with the pinned version
- **THEN** CI fails with an annotation naming each skill that differs from the first skill's stamp state

#### Scenario: OpenSpec version record missing or not exact
- **WHEN** an install pin or `TEMPLATE_SOURCE.md` row is missing, a record appears more than once (including two `generatedBy` lines in one skill), or a record is not an exact `MAJOR.MINOR.PATCH` version (for example `^1.17.0` or `latest`)
- **THEN** CI fails and names the file of that record

#### Scenario: Ponytail pin records disagree
- **WHEN** the pinned commit in any `.agents/skills/ponytail*/SOURCE.md` (its "Pinned commit" value or the commit in its "File at that commit" link), or its `git describe` string, differs from the commit or `git describe` string in the Ponytail row of the Sources table of `TEMPLATE_SOURCE.md`, or any of those records is missing or is not a full 40-character commit SHA
- **THEN** CI fails and names the file and line of each such record

#### Scenario: Vendored Ponytail file does not match its recorded fingerprint
- **WHEN** the SHA-256 of a vendored Ponytail `SKILL.md` or `LICENSE` differs from the value recorded in that folder's `SOURCE.md`
- **THEN** CI fails and names the file with both values

#### Scenario: Generated skills match the pinned OpenSpec version
- **WHEN** every file under `.agents/skills/openspec-*/` and `.agents/skills/.openspec-target` is byte-identical to what `openspec init --scope project --tools agents --profile core` writes at the version pinned in `.github/workflows/ci.yml`, with no other file in those paths
- **THEN** the generated-skills check passes and prints how many generated files matched and the version

#### Scenario: Generated skill edited
- **WHEN** a generated skill file differs from what the pinned version generates (a hand edit to its text, or an added, removed or edited `generatedBy` stamp)
- **THEN** CI fails with a `::error file=<path>,line=1::` annotation for that file that says it was edited and gives the fix: run `npx -y @fission-ai/openspec@<pin> update` (or `init --scope project --tools agents --profile core`) and commit the result, or revert the hand edit

#### Scenario: Generated skill file missing
- **WHEN** a file the pinned version generates is missing from the checkout, including a whole deleted `openspec-*` skill folder
- **THEN** CI fails with a `::error file=<path>,line=1::` annotation for each missing file that says it is missing and gives the fix: run `npx -y @fission-ai/openspec@<pin> init --scope project --tools agents --profile core` and commit the result, or restore it from git

#### Scenario: Extra or untracked file in generated skills
- **WHEN** a file the pinned version does not generate exists under `.agents/skills/openspec-*/`, including a new `openspec-*` folder, whether tracked or untracked
- **THEN** CI fails with a `::error file=<path>,line=1::` annotation for each such file that says it is extra (or untracked) and gives the fix: delete it, or keep a custom skill under a name that does not start with `openspec-`

#### Scenario: Parent directory linked only on disk or only in the index
- **WHEN** `.agents` or `.agents/skills` is a symbolic link in the working tree while the index still records a real directory (an uncommitted link), or the index records it as a link (mode 120000) while the working tree holds a real directory
- **THEN** CI fails with a `::error file=<dir>,line=1::` annotation for that directory that says `symlink`, so neither half of the check depends on the other

#### Scenario: Generated file present but not committed
- **WHEN** a file the pinned version generates is in the checkout with the generated content but is not committed
- **THEN** CI fails with a `::error file=<path>,line=1::` annotation for that file that says it is untracked and gives the fix: commit it with `git add`

#### Scenario: Generated skill mode or file type changed
- **WHEN** a generated path in the checkout is a symbolic link, including a link to an identical copy and an uncommitted link over a tracked file, or `.agents` or `.agents/skills` is a symbolic link on disk or in the index, or a generated file's git mode differs from what the pinned version writes (for example a committed `chmod +x`, mode 100755, where `init` writes 100644), tracked or untracked
- **THEN** CI fails with a `::error file=<path>,line=1::` annotation for that file or directory that says `symlink` or `mode` with both modes, and gives the fix: replace the link with the generated file or a real directory, or reset the mode with `git update-index --chmod=-x` (or `+x`) and `chmod` (for an untracked file, `chmod` and `git add`), and commit

#### Scenario: Reference version comes from the CI pin
- **WHEN** the `@fission-ai/openspec@<version>` install line in `.github/workflows/ci.yml` is missing or not an exact `MAJOR.MINOR.PATCH` (even when the CLI reports the same string), two such lines name different versions, or the OpenSpec CLI the check runs reports a different version from that pin
- **THEN** CI fails with a `::error file=` annotation naming `.github/workflows/ci.yml` (and both versions when they differ) and never generates the reference from `latest` or another version

#### Scenario: Check leaves the checkout unchanged
- **WHEN** the generated-skills check runs, whether it passes or fails
- **THEN** it generates the reference only in a temporary directory outside the checkout with temporary OpenSpec config and data directories and a temporary `HOME` (never the caller's `XDG_CONFIG_HOME`, `XDG_DATA_HOME` or `HOME`, so a global skills install cannot land in the caller's home directory), removes that temporary directory when it exits, and `git status --porcelain --untracked-files=all` of the checkout is the same before and after, so later CI steps see the files as committed

#### Scenario: Reference generation fails
- **WHEN** `openspec init --scope project --tools agents --profile core` exits non-zero in the temporary directory, or exits zero but writes no generated skill files
- **THEN** CI fails with a `::error file=` annotation naming `.github/workflows/ci.yml` that says the generation failed (with its output) or generated no skill files, and never reports a match
