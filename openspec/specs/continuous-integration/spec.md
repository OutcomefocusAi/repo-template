# continuous-integration Specification

## Purpose

Runs the same quality and safety checks on every pull request and every push to `main`, hardened against supply-chain and token abuse, with stack-specific steps left as slots a project fills.

## Requirements

### Requirement: CI runs on every pull request and push to main
A CI workflow SHALL run on `pull_request` and on `push` to `main`. It SHALL NOT use `pull_request_target`.

#### Scenario: Pull request opened
- **WHEN** a pull request targets `main`
- **THEN** the CI workflow runs against its head

#### Scenario: Forbidden trigger
- **WHEN** a reviewer searches the workflows for `pull_request_target`
- **THEN** there are no matches

### Requirement: Workflows are hardened
Every workflow SHALL pin each third-party action to a full commit SHA with the version in a comment, set top-level `permissions` to `contents: read` and raise permissions only per job where needed, set `concurrency` that cancels superseded runs on pull requests, and set `timeout-minutes` on every job.

#### Scenario: Unpinned action
- **WHEN** a workflow references an action by tag or branch instead of a 40-character SHA
- **THEN** the template checks job fails and names the line

#### Scenario: Job without timeout
- **WHEN** a job has no `timeout-minutes`
- **THEN** the template checks job fails and names the job

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

#### Scenario: Generated skills match the pinned OpenSpec version
- **WHEN** every file under `.agents/skills/openspec-*/` and `.agents/skills/.openspec-target` is byte-identical to what `openspec init --tools agents --profile core` writes at the version pinned in `.github/workflows/ci.yml`, with no other file in those paths
- **THEN** the generated-skills check passes and prints how many generated files matched and the version

#### Scenario: Generated skill edited
- **WHEN** a generated skill file differs from what the pinned version generates (a hand edit to its text or its `generatedBy` stamp)
- **THEN** CI fails with a `::error file=<path>,line=1::` annotation for that file that says it was edited and gives the fix: run `npx -y @fission-ai/openspec@<pin> update` (or `init --tools agents --profile core`) and commit the result, or revert the hand edit

#### Scenario: Generated skill file missing
- **WHEN** a file the pinned version generates is missing from the checkout, including a whole deleted `openspec-*` skill folder
- **THEN** CI fails with a `::error file=<path>,line=1::` annotation for each missing file that says it is missing and gives the fix: run `npx -y @fission-ai/openspec@<pin> init --tools agents --profile core` and commit the result, or restore it from git

#### Scenario: Extra or untracked file in generated skills
- **WHEN** a file the pinned version does not generate exists under `.agents/skills/openspec-*/`, including a new `openspec-*` folder, whether tracked or untracked
- **THEN** CI fails with a `::error file=<path>,line=1::` annotation for each such file that says it is extra (or untracked) and gives the fix: delete it, or keep a custom skill under a name that does not start with `openspec-`

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
- **THEN** it generates the reference only in a temporary directory outside the checkout with temporary OpenSpec config and data directories (never the caller's `XDG_CONFIG_HOME` or `XDG_DATA_HOME`), removes that temporary directory when it exits, and `git status --porcelain --untracked-files=all` of the checkout is the same before and after, so later CI steps see the files as committed

#### Scenario: Reference generation fails
- **WHEN** `openspec init --tools agents --profile core` exits non-zero in the temporary directory, or exits zero but writes no generated skill files
- **THEN** CI fails with a `::error file=` annotation naming `.github/workflows/ci.yml` that says the generation failed (with its output) or generated no skill files, and never reports a match

### Requirement: Stack steps are marked slots
The CI workflow SHALL contain lint, typecheck, test, coverage gate, and build steps as clearly marked slots. The first project proposal in a derived repository SHALL fill every slot with the stack's real commands.

#### Scenario: Slot markers
- **WHEN** a reviewer reads the CI workflow in the template
- **THEN** each of the five steps carries a `SLOT` marker naming what the project must supply

### Requirement: Unfilled slots fail outside the template
When CI runs in any repository other than `OutcomefocusAi/repo-template`, a slot still marked unfilled SHALL fail the run. In the template repository itself an unfilled slot SHALL pass with a visible warning.

#### Scenario: Derived repository with unfilled slot
- **WHEN** CI runs in a repository created from the template and a slot is still unfilled
- **THEN** that step fails with a message pointing to the first project proposal

#### Scenario: Template repository
- **WHEN** CI runs in `OutcomefocusAi/repo-template`
- **THEN** unfilled slots pass and emit a warning annotation

### Requirement: Coverage gate enforces the testing bar
The coverage slot SHALL fail CI when line coverage on new code is below 80%, and on paths a project marks as money or critical is below 90%.

#### Scenario: Coverage below bar
- **WHEN** a filled coverage step measures 79% line coverage on new code
- **THEN** CI fails

### Requirement: CI stays within the free minutes budget
CI jobs SHALL run on standard Linux GitHub-hosted runners only, and no workflow SHALL upload artifacts unless a project proposal adds one with a retention period.

#### Scenario: Runner choice
- **WHEN** a reviewer reads `runs-on` across the workflows
- **THEN** every job uses a standard Linux runner label
