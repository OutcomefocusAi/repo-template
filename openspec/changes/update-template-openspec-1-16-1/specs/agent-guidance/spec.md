## MODIFIED Requirements

### Requirement: Skills live in .agents/skills
OpenSpec-generated skills SHALL live in `.agents/skills/openspec-*/` as produced by `openspec init --tools agents` and refreshed with `openspec update` at the pinned OpenSpec version, and `AGENTS.md` SHALL name the skill for each workflow step that has one.

#### Scenario: Skills present
- **WHEN** a reviewer lists `.agents/skills/`
- **THEN** it contains the six OpenSpec skills (propose, explore, apply-change, update-change, sync-specs, archive-change) unmodified from generation

#### Scenario: OpenSpec pin records agree
- **WHEN** a reviewer reads the `generatedBy` value in each `.agents/skills/openspec-*/SKILL.md`, the `@fission-ai/openspec` install line in `.github/workflows/ci.yml`, and the OpenSpec rows in the Sources and Tool pins tables of `TEMPLATE_SOURCE.md`
- **THEN** all of them name the same exact OpenSpec version
