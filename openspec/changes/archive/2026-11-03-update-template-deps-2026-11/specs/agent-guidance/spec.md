## MODIFIED Requirements

### Requirement: Ponytail skills are vendored at a pinned commit
The repository SHALL vendor the ponytail, ponytail-review, and ponytail-audit skills under `.agents/skills/` byte for byte from the pinned upstream commit, each with its LICENSE and a SOURCE.md naming the commit, the upstream version, and the SHA-256 of its SKILL.md and LICENSE.

#### Scenario: Vendored copies match
- **WHEN** a reviewer compares SHA-256 values of the vendored SKILL.md and LICENSE files with the same files in `DietrichGebert/ponytail` at the commit named in each SOURCE.md
- **THEN** they match, and they match the SHA-256 values recorded in that SOURCE.md

#### Scenario: Pin records agree
- **WHEN** a reviewer reads `TEMPLATE_SOURCE.md` and each vendored skill's SOURCE.md
- **THEN** both name the same upstream commit and version
