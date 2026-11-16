# Design: update-template-openspec-2-0-0

## Context

See proposal.md for why. Today `.github/workflows/ci.yml` installs `@fission-ai/openspec@1.17.0`, both OpenSpec rows of `TEMPLATE_SOURCE.md` say 1.17.0, and the six generated skills carry `generatedBy: "1.17.0"` and 28 lines that mention slash commands. The template configures one tool, `agents`, so its skills already live only in `.agents/skills/` and it has no command files; the 2.0 move to one shared skills folder changes nothing in its layout. The box's global `openspec` is 1.14.3 and is not used; every check ran with `npx -y @fission-ai/openspec@<version>` in a throwaway npm cache under `/tmp`, with the user config directory pointed at `/tmp` so no global OpenSpec config was written.

Facts checked on 2026-11-16 (re-checked in task 1.2; command output goes in this change's `evidence/` folder on apply):

- npm `@fission-ai/openspec` 2.0.0 published 2026-11-11 22:46 UTC (3:46 PM AZ), dist-tag `latest`. `engines.node >=22.12.0`, same as 1.17.0. License MIT.
- GitHub release `v2.0.0` ("Skills in .agents/skills, /opsx commands removed"), published 2026-11-11 22:41 UTC: https://github.com/Fission-AI/OpenSpec/releases/tag/v2.0.0. Six commits from `v1.17.0`: skills only in one shared folder (#2223, the breaking change), wrapped tasks kept whole (#2228), cmd.exe completion fix (#2229), CI and docs-test commits (#2237, #2240) and the version commit.
- `openspec update --dry-run` at 2.0.0 on a scratch copy of `origin/main` `8c529c4` lists the six `.agents/skills/openspec-*/SKILL.md` files and nothing else in the repository. The real run modifies those six files (35 insertions, 35 deletions), adds or removes no file and adds no em dash. After it, a search for `/openspec-`, `/opsx` and `slash` in those skills finds nothing.
- `openspec validate --all --strict` at 2.0.0 on the scratch copy: 8 passed, 0 failed. `openspec --help` at 2.0.0 is byte-identical to 1.17.0.
- With the pin in `ci.yml` and both `TEMPLATE_SOURCE.md` rows hand-edited to 2.0.0: `scripts/check-openspec-pin.sh` prints "9 records agree on 2.0.0"; `scripts/test-template-scripts.sh` passes 97 of 97; `check-em-dash.sh`, `check-ponytail-pin.sh`, `check-workflows.sh`, actionlint and gitleaks (145 commits) pass.

## Goals / Non-Goals

**Goals:**
- Template pins OpenSpec 2.0.0, with the generated skills exactly as 2.0.0 produces them.
- A spec scenario records the 2.0 behavior that skills are invoked by name and no slash-command files exist, so a later drift check or review can test it.

**Non-Goals:**
- Any Ponytail change.
- Node.js, gitleaks, actionlint or actions pins; the standalone OpenSpec binary; the extra OpenSpec workflows `openspec update` mentions (new, continue, ff, bulk-archive, verify, onboard); configuring any tool besides `agents`.
- Any `AGENTS.md`, `README.md` or script change. `AGENTS.md` names skills by path and has no slash-command text.
- Upgrading the box's global `openspec`.

## Decisions

1. **2.0.0, the npm `latest`, through a proposal.** Its skill wording change goes beyond the stamps the standing OK covers. Staying on 1.x is supported upstream, but the weekly check would flag it every week and the change for this template is small.
2. **Regenerate with `openspec update`, not `openspec init --tools agents`.** Same path as #28 and #30. If the real run adds, removes or changes any file beyond the six skills, or changes their text beyond what proposal.md lists, stop and report before committing.
3. **Spec delta on "Skills live in .agents/skills".** The behavior that actually changes for users of the template is how skills are invoked. A scenario that searches for slash-command wording and command folders fails on today's `main` (28 matching lines) and passes after the update, so it is a real check, not a placeholder. Alternative considered: `skip_specs: true`; rejected because the invocation behavior does change. Alternative considered: a CI script for the new scenario; rejected for now, because `openspec update` produces this state and the pin check already catches a skipped regeneration through the stamps.
4. **No pin-check change.** `check-openspec-pin.sh` locates the nine records by pattern and names no version, so a major version passes the same `MAJOR.MINOR.PATCH` rule.

## Verification plan

- Local: `npx -y @fission-ai/openspec@2.0.0 --version` reports 2.0.0; `openspec update` then `git diff --stat` shows only the six skills; `git diff` shows only the stamp and wording changes listed in proposal.md.
- `rg -n "1\.17\.0"` outside `openspec/changes/` finds nothing except the `^1.17.0` example in `openspec/specs/continuous-integration/spec.md`; `scripts/check-openspec-pin.sh` reports 9 records agree on 2.0.0.
- The new scenario: `rg -n "/openspec-|/opsx|slash command" .agents/skills/openspec-*/` finds nothing, and no `commands/opsx` or `commands/openspec` folder exists anywhere in the repository.
- Repository checks: `openspec validate --all --strict` at 2.0.0, `scripts/test-template-scripts.sh`, `scripts/check-em-dash.sh`, `scripts/check-ponytail-pin.sh`, `scripts/check-workflows.sh`, actionlint, gitleaks over the full history, `scripts/check-commits.sh` and `git diff --check`.
- CI: `template-checks` installs 2.0.0 from the bumped line and its log shows the version; `project` green; then Principal QA review and `qa-gate`.

## Risks / Trade-offs

- [Skill text tells agents to invoke skills by name instead of slash command] → Tools that list skills as slash commands keep working; `AGENTS.md` already points to skill paths. QA reads the full skill diff.
- [`openspec update` at 2.0 deletes unedited files from older versions] → The scratch run deleted nothing here; task 2.2 stops if the real run adds or removes any file.
- [Derived repositories with other tools get linked skill folders] → Not part of the template; noted in the pull request for derived repositories. Windows needs `core.symlinks`, otherwise `update` writes plain copies.
- [Major release only five days old] → Re-checked on the day of apply (task 1.2); if a 2.0.x patch is out, stop and report so the proposal can be retargeted.
- [Workflow file edit] → The pull request runs its own `qa-gate` copy; QA checks the one-line diff in `ci.yml`.

## Migration Plan

Apply on the issue branch, one commit per task group, archive as the last commit before QA, then Woody's merge. Rollback: revert the squash-merge commit on `main`, which restores 1.17.0, the old skill text and the old requirement text; no data or settings to migrate.
