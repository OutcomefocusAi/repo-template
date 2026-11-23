## MODIFIED Requirements

### Requirement: Ponytail skills are vendored at a pinned commit
The repository SHALL vendor the ponytail, ponytail-review, and ponytail-audit skills under `.agents/skills/` byte for byte from the pinned upstream commit, each with its LICENSE and a SOURCE.md naming the commit, the upstream version, and the SHA-256 of its SKILL.md and LICENSE.

#### Scenario: Vendored copies match
- **WHEN** a reviewer compares SHA-256 values of the vendored SKILL.md and LICENSE files with the same files in `DietrichGebert/ponytail` at the commit named in each SOURCE.md
- **THEN** they match, and they match the SHA-256 values recorded in that SOURCE.md

#### Scenario: Pin records agree
- **WHEN** a reviewer reads `TEMPLATE_SOURCE.md` and each vendored skill's SOURCE.md
- **THEN** both name the same upstream commit and version

#### Scenario: Re-vendor at a commit that changes no vendored file
- **WHEN** the pin moves to a newer upstream commit (for example `96608e0` to `ebd8654c2c627f721eb8f9c0d1bd4090a29f9e10`) and `git diff <old> <new> -- skills/ponytail skills/ponytail-review skills/ponytail-audit LICENSE` upstream is empty
- **THEN** every vendored SKILL.md and LICENSE stays byte-identical with the same recorded SHA-256, and each SOURCE.md and the `TEMPLATE_SOURCE.md` Ponytail row name the new full commit, its `git describe --tags` string (`v5.3.3-4-gebd8654`) and the new vendored date

### Requirement: Skills live in .agents/skills
OpenSpec-generated skills SHALL live in `.agents/skills/openspec-*/` as produced by `openspec init --scope project --tools agents` and refreshed with `openspec update` at the pinned OpenSpec version, and `AGENTS.md` SHALL name the skill for each workflow step that has one. The skills SHALL stay in the repository (`skillsScope: project` in `openspec/config.yaml`), SHALL be invoked by skill name, and the repository SHALL carry no OpenSpec slash-command files.

#### Scenario: Skills present
- **WHEN** a reviewer lists `.agents/skills/`
- **THEN** it contains the six OpenSpec skills (propose, explore, apply-change, update-change, sync-specs, archive-change) unmodified from generation

#### Scenario: OpenSpec pin records agree
- **WHEN** a reviewer reads the `@fission-ai/openspec` install line in `.github/workflows/ci.yml`, the OpenSpec rows in the Sources and Tool pins tables of `TEMPLATE_SOURCE.md`, and any `generatedBy` value in the `.agents/skills/openspec-*/SKILL.md` files
- **THEN** all of them name the same exact OpenSpec version, and the skills are byte-identical to what that version generates (at 2.1.x they carry no `generatedBy` stamp)

#### Scenario: Skills are invoked by name
- **WHEN** a reviewer searches `.agents/skills/openspec-*/` for `/openspec-`, `/opsx` and `slash command`, and lists the repository for OpenSpec command folders (such as `.claude/commands/opsx/`)
- **THEN** the search finds nothing and no such folder exists

#### Scenario: Skills stay in the repository
- **WHEN** someone runs `openspec update` interactively at the pinned version in the template or a repository created from it
- **THEN** OpenSpec reads `skillsScope: project` from `openspec/config.yaml`, does not offer to switch the skills to a global install, and refreshes them in `.agents/skills/`
