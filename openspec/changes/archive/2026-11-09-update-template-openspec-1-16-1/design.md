# Design: update-template-openspec-1-16-1

## Context

See proposal.md for why. Today `.github/workflows/ci.yml` installs `@fission-ai/openspec@1.16.0`, both OpenSpec rows of `TEMPLATE_SOURCE.md` say 1.16.0, and the six generated skills carry `generatedBy: "1.16.0"`. The box's global `openspec` is 1.14.3 and is not used for this change; every check below ran with `npx -y @fission-ai/openspec@<version>` in a throwaway npm cache under `/tmp`.

This design first targeted 1.16.1. Task 1.2 on 2026-11-09 8:34 PM AZ found npm `latest` at 1.17.0 (output in `evidence/0-upstream-check-before-retarget.txt`), and Woody chose to retarget to 1.17.0 (see proposal.md, Approval). The 1.16.1 facts below stay because 1.17.0 includes them.

Facts checked on 2026-11-09 (re-checked in task 1.2; command output goes in this change's `evidence/` folder on apply):

- npm `@fission-ai/openspec`: 1.16.1 published 2026-11-07 00:46 UTC (2026-11-06 5:46 PM AZ); 1.17.0 published 2026-11-09 23:48 UTC (4:48 PM AZ), dist-tag `latest`. License MIT. `engines.node >=22.12.0`, same as 1.16.0.
- GitHub release `v1.16.1` ("Spec parsing, version checks"), published 2026-11-07 00:44 UTC: https://github.com/Fission-AI/OpenSpec/releases/tag/v1.16.1. Eight commits from `v1.16.0`: parser accepts closing `#` runs (#2205), `validate` rejects unrecognized delta sections (#2207), `version --check` runs with telemetry off (#2204), standalone update offers only released builds (#2206), minimatch forced to `>=11.0.1` for GHSA-g3hv-75wg-m249 (#2192), two dependency bumps and the version commit. No file under the skill templates changed.
- GitHub release `v1.17.0`, published 2026-11-09 23:46 UTC: https://github.com/Fission-AI/OpenSpec/releases/tag/v1.17.0. Five commits from `v1.16.1`: `update` upgrades from any release and warns that command files go away in 2.0 (#2213), Windows installer CPU detection (#2222), two dependency bumps and the version commit. The only skill-related source file changed is `src/core/shared/skill-content-equivalence.ts` (how `update` decides a generated file is unedited), not a skill template.
- `openspec update --dry-run` at 1.17.0 on a scratch copy of `origin/main` `e0cb3c2` lists the six `.agents/skills/openspec-*/SKILL.md` files. The real run changes one line in each (`generatedBy: "1.16.0"` to `"1.17.0"`), adds or removes no file, prints no 2.0 notice (skills only) and adds no em dash. `openspec validate --all --strict` at 1.17.0 on `e0cb3c2`: 8 passed, 0 failed.
- Earlier 1.16.1 check: `openspec update --dry-run` at 1.16.1 on a scratch copy of `origin/main` `e0cb3c2` lists the six `.agents/skills/openspec-*/SKILL.md` files. The real run changes one line in each (`generatedBy: "1.16.0"` to `"1.16.1"`), adds or removes no file and adds no em dash.
- `openspec validate --all --strict` at 1.16.1 on `e0cb3c2`: 8 passed, 0 failed.
- Ponytail upstream `HEAD` is still `96608e078b2d5ea607c5c3b8b5a54d1c1fba6846` per Chief of Staff's drift check; task 1.2 re-checks it.

## Goals / Non-Goals

**Goals:**
- Template pins OpenSpec 1.17.0, with the generated skills matching that version exactly.
- The four places that record the OpenSpec version are covered by a spec scenario, so the next drift check can test them.

**Non-Goals:**
- Any Ponytail change. The vendored skills, their `SOURCE.md` files and the Ponytail row of `TEMPLATE_SOURCE.md` stay as they are.
- Node.js, gitleaks, actionlint, or actions pins; the standalone OpenSpec binary; the extra OpenSpec workflows `openspec update` mentions (new, continue, ff, bulk-archive, verify, onboard); any `AGENTS.md` change.
- Upgrading the box's global `openspec` outside the apply tasks.

## Decisions

1. **1.17.0, the npm `latest`, not 1.16.1.** Woody chose it when 1.17.0 appeared on the day of apply. It is a minor release with no breaking change and no skill template change; current specs pass its validation, and its `update` changes the same six lines. Stopping at 1.16.1 would leave the template a release behind on merge day. Keeping the change name `update-template-openspec-1-16-1` is explained in proposal.md.
2. **Regenerate with `openspec update`, not `openspec init --tools agents`.** Same as #28: the scratch run shows it produces exactly the version-stamp change. If the real run adds, removes or changes anything beyond the six `generatedBy` lines, stop and report before committing.
3. **Spec delta on "Skills live in .agents/skills".** The 1.16.0 change modified the Ponytail requirement and left the OpenSpec one alone. This change modifies the OpenSpec requirement in the same `agent-guidance` capability. Two reasons, both about real behavior rather than satisfying validation: the requirement says the skills are "produced by `openspec init --tools agents`" while every refresh since bootstrap used `openspec update`; and no scenario checks that the `generatedBy` stamp, the CI install pin and `TEMPLATE_SOURCE.md` agree, which is exactly what a missed step in a bump would break. Like the Ponytail requirement, the delta names no version, so later bumps need no spec text change. Alternative considered: `skip_specs: true` with no delta; rejected because the gap above is real and cheap to close now.
4. **No `SOURCE.md` for the OpenSpec skills.** Generated files are recorded in `TEMPLATE_SOURCE.md` and stamped with `generatedBy`; adding a `SOURCE.md` would be a fifth record to keep in step for no new information.

## Verification plan

- Local: `npx -y @fission-ai/openspec@1.17.0` (or a temporary prefix install) reports 1.17.0; `openspec update` then `git diff` shows only the six `generatedBy` lines; `openspec validate --all --strict` passes at 1.17.0.
- `rg -n "1\.16\.0"` outside `openspec/changes/` finds nothing, and `rg -n "1\.17\.0"` finds the six skills, `ci.yml` and both `TEMPLATE_SOURCE.md` rows (the new scenario).
- Repository checks: `scripts/test-template-scripts.sh`, `scripts/check-em-dash.sh`, `scripts/check-workflows.sh`, actionlint, gitleaks over the full history, `scripts/check-commits.sh` and `git diff --check`.
- CI: `template-checks` installs 1.17.0 from the bumped line and its log shows the version; `project` green; then Principal QA review and `qa-gate`.

## Risks / Trade-offs

- [Unrecognized delta sections now fail `validate` (from 1.16.1)] → Every current spec passes at 1.17.0. Archived changes are not validated. A derived repository with a non-standard section must rename it; note it in the PR.
- [`openspec version --check` now runs in CI if invoked] → CI does not invoke it; `OPENSPEC_NO_UPDATE_CHECK` still skips it.
- [1.17.0 `update` removes unedited old OpenSpec files] → The scratch run removed nothing here; task 2.2 stops if the real run adds or removes any file.
- [Transitive npm dependencies use caret ranges] → Unchanged; 1.16.1 and later force minimatch `>=11.0.1` for an advisory. gitleaks and CI run on every push.
- [Workflow file edit] → The pull request runs its own `qa-gate` copy; QA checks the one-line diff in `ci.yml`.

## Migration Plan

Apply on the issue branch, one commit per task group, archive as the last commit before QA, then Woody's merge. Rollback: revert the squash-merge commit on `main` (restores 1.16.0 and the old requirement text); no data or settings to migrate.
