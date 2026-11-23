# Proposal: update-template-openspec-2-1-1

Tracking issue: [#47](https://github.com/OutcomefocusAi/repo-template/issues/47). Branch: `47-update-template-openspec-2-1-1`, from `main` `3166c89ac43179aa1ecc690c2d40decdfbdb9d96` (OpenSpec 2.0.0, Ponytail `96608e0`). Folds in [#46](https://github.com/OutcomefocusAi/repo-template/issues/46) (`harden-openspec-ci-install`). Not docs-only and not covered by the standing OK for version-only bumps: OpenSpec 2.1.x changes how `openspec init` installs skills, drops the `generatedBy` stamp the pin check reads, and rewrites skill instructions, so the checks themselves change (see Approval).

## Approval

| What | Words or selected option text | How given, where and when |
| --- | --- | --- |
| Keep the template's OpenSpec and Ponytail current (the request behind this change) | Typed by Woody: "in reference to the template repo I set up I wanna make sure those always have the current version of ponytail and open spec so can you check GitHub once a week to see if they are current and if not get those updated so that template always stays current" | Typed in Woody's chat with Chief of Staff, 2026-11-03 8:46 AM AZ. Relayed by Chief of Staff to Principal Engineer on 2026-11-23 8:15 AM AZ as a drift finding from the weekly check. A request to update, not approval of this proposal |
| Standing OK for version-only bumps (does not apply here) | Selected option: "Yes, standing OK for version-only bumps" on the card "Want a standing OK for the weekly template updates? When only the OpenSpec or Ponytail version changes, I'd apply it, Principal QA reviews it, and it merges after a SHIP verdict with no tap from you. Anything bigger still comes to you first." | Tapped by Woody in Principal Engineer's chat at 2026-11-09 8:34 PM AZ. Covers repo-template PRs that only change the OpenSpec or Ponytail versions. This change is bigger, so the two records below are what authorize it |
| Draft this proposal | Selected option: "Approve drafting a full OpenSpec 2.1.1 proposal that also updates Ponytail and folds in issue #46 (the install cutoff hardening). This is not a merge approval." on the card "The OpenSpec 2.1.1 update for repo-template changes how its tools behave, so it needs your OK. How should I proceed?" | Tapped by Woody in Chief of Staff's chat at 2026-11-23 8:20 AM AZ, relayed by Chief of Staff. Covers: opening the issue and branch, drafting and validating the proposal for the 2.1.1 pin, Ponytail `ebd8654` and the #46 cutoff hardening. Not covered: implementation, merging |
| Approve the proposal, apply, fixes and merge | Typed by Woody: "you have my approval for all fixes, merges, etc. to get this updated. Don't ask again, just go until it's done" | Typed in Woody's chat with Chief of Staff at 2026-11-23 8:20 AM AZ, relayed by Chief of Staff. Covers: proposal approval, apply, fixes for the OpenSpec 2.1.1 + Ponytail `ebd8654` + #46 update end to end (his words also name merges; the merge still waits for Principal QA's `SHIP` on the final head and green CI). Not covered: weakening or bypassing any check, force-push, PATs or permission changes, anything outside this update |

## Why

The template pins `@fission-ai/openspec` 2.0.0 and Ponytail `96608e0`. Upstream released OpenSpec 2.1.0 (npm 2026-11-17 01:15 UTC) and 2.1.1 (npm `latest`, 2026-11-19 22:29 UTC, 3:29 PM AZ), and Ponytail `main` moved to `ebd8654` (`v5.3.3-4-gebd8654`). A plain pin bump does not work: at 2.1.1 the pin check fails on all six skills (`expected exactly one generatedBy line, found 0`) and the generated-skills check fails (`init --tools agents --profile core' generated no skill files`), because `init` in a new repository now installs skills globally into `~/.agents/skills/`. Separately, #46 showed that the CI install resolves OpenSpec's dependency ranges fresh on every run, so any upstream publish can break or change CI; the-ordinary-things fixed this in PR #18 (merged as `22a924a`), and the template should carry the same fix so every derived repository gets it.

## What Changes

- **OpenSpec 2.1.1.** Bump the pin in `.github/workflows/ci.yml` and both `TEMPLATE_SOURCE.md` rows, and change the Tool pins note to "needs Node.js 22.20.0 or newer" (`engines.node` moved from `>=22.12.0` to `>=22.20.0`; CI runs Node 24.22.1). Regenerate `.agents/skills/openspec-*/` with `openspec update` at 2.1.1. A scratch run on `main` `3166c89` modifies the same six `SKILL.md` files (30 insertions, 29 deletions) and adds or removes no file:
  - the `generatedBy` stamp line is removed from every skill;
  - `openspec-archive-change` checks the archive target before syncing any main spec and again before the move, and may do the delta merge inline when the sync skill is not installed;
  - `openspec-apply-change` and `openspec-update-change` point to "ask to archive" or the `openspec archive` command instead of naming other skills; `openspec-explore` and `openspec-propose` reword hand-offs; `openspec-sync-specs` loses its stamp only.
- **Keep skills in the repository.** Record `skillsScope: project` in `openspec/config.yaml` (the 2.1.x key for "Keep in this project"), so an interactive `openspec update` never offers to move the skills to a global install and delete them from the repository.
- **Stamp-free pin coverage.** `scripts/check-openspec-pin.sh` stops requiring a `generatedBy` stamp: a skill may carry at most one, a stamp that is present must equal the CI pin, and the skills must be all stamped or all unstamped. The generated-skills check (byte-identical to what the pinned CLI generates) remains the record that ties skill content to the pin, so no drift that failed CI before passes now.
- **Generated-skills check at 2.1.x.** `scripts/check-openspec-skills.sh` generates its reference with `openspec init --scope project --tools agents --profile core`, with a temporary `HOME` as well as temporary XDG directories, so the reference is written in the temporary repository and nothing reaches the caller's home directory. Its fix hints and `TEMPLATE_SOURCE.md` say the same.
- **#46, OpenSpec install cutoff.** Port the-ordinary-things `22a924a`: the CI install line becomes exactly `npm install --global --no-fund --no-audit --before=2026-11-21T00:00:00Z @fission-ai/openspec@2.1.1`; the pin check requires that exact shape (one cutoff, nothing that overrides or exempts it, nothing after the package), a cutoff that round-trips through `date` as a real UTC time, is not earlier than 2020-01-01T00:00:00Z and not later than now, matches the cutoff recorded in the `TEMPLATE_SOURCE.md` Tool pins row, and no `npm_config_*` in any workflow.
- **QA follow-ups from the-ordinary-things PR #18, included because they fit the same check:**
  - [the-ordinary-things#25](https://github.com/OutcomefocusAi/the-ordinary-things/issues/25): reject an install line continued from the line before (`\`), an install inside a folded `run: >` block (or any block that is not a literal `run: |`), and any workflow text that writes npm config (`npmrc`, `npm config set`, `npm set`).
  - [the-ordinary-things#26](https://github.com/OutcomefocusAi/the-ordinary-things/issues/26): scan `.github/workflows/*.yaml` as well as `*.yml`.
  - [the-ordinary-things#27](https://github.com/OutcomefocusAi/the-ordinary-things/issues/27): self-tests assert file and line for the Tool pins row mismatch, row missing and npm config annotations, and cover lowercase `npm_config_`.
- **Ponytail `ebd8654`.** Re-vendor `ponytail`, `ponytail-review` and `ponytail-audit` at `ebd8654c2c627f721eb8f9c0d1bd4090a29f9e10`. Upstream changed nothing under `skills/` or `LICENSE` since `96608e0` (three commits: README, hooks and tests), so `SKILL.md` and `LICENSE` stay byte-identical and their SHA-256 values do not change; each `SOURCE.md` and the `TEMPLATE_SOURCE.md` row get the new commit, `git describe` string and vendored date.
- Upstream sources: [OpenSpec v2.1.0](https://github.com/Fission-AI/OpenSpec/releases/tag/v2.1.0), [v2.1.1](https://github.com/Fission-AI/OpenSpec/releases/tag/v2.1.1), [compare v2.0.0...v2.1.1](https://github.com/Fission-AI/OpenSpec/compare/v2.0.0...v2.1.1), [Ponytail 96608e0...ebd8654](https://github.com/DietrichGebert/ponytail/compare/96608e078b2d5ea607c5c3b8b5a54d1c1fba6846...ebd8654c2c627f721eb8f9c0d1bd4090a29f9e10), [the-ordinary-things 22a924a](https://github.com/OutcomefocusAi/the-ordinary-things/commit/22a924acf859da23a4903aaeae987324ca77c3cc).

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `agent-guidance`: "Skills live in .agents/skills" says the skills stay in the repository (`--scope project`, `skillsScope: project`) and the pin records no longer need a stamp; "Ponytail skills are vendored at a pinned commit" gains a scenario for a re-vendor that changes no vendored byte.
- `continuous-integration`: "Template checks always run" changes the OpenSpec version-record scenarios for stamp-free skills and the generated-skills scenarios for `init --scope project` and a temporary `HOME`.
- `supply-chain-security`: "Third-party tools are pinned and license-checked" gains the npm `--before` cutoff rule, its scenarios (from #46 and the-ordinary-things#25, #26) and the recorded Node.js minimum.

## Impact

- `.github/workflows/ci.yml`: one line, the OpenSpec install (version and `--before`). The pull request edits a workflow file, so it runs its own `qa-gate` copy and its body says "Workflow files changed: yes".
- `scripts/check-openspec-pin.sh`, `scripts/check-openspec-skills.sh`, `scripts/test-template-scripts.sh`.
- `.agents/skills/openspec-*/SKILL.md` (generated), `.agents/skills/ponytail*/SOURCE.md`, `openspec/config.yaml`, `TEMPLATE_SOURCE.md`.
- `openspec/specs/agent-guidance/spec.md`, `continuous-integration/spec.md`, `supply-chain-security/spec.md`, at archive.
- No change to `AGENTS.md`, `README.md`, the vendored Ponytail `SKILL.md` or `LICENSE` files, Node.js, other actions or binaries, rulesets or settings. No new dependency, account or spending.
- Risks: derived repositories keep the old checks until they take the next template release; a pin bump now also has to move the cutoff (the install fails loudly with `ETARGET` otherwise); the npm config text rule could reject a future legitimate workflow line that mentions `npmrc` (it then needs its own change).
