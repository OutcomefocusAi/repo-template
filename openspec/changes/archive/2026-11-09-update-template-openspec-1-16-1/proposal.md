# Proposal: update-template-openspec-1-16-1

Tracking issue: [#30](https://github.com/OutcomefocusAi/repo-template/issues/30). Branch: `30-update-template-openspec-1-16-1`. Notion Tasks row: https://app.notion.com/p/413444b092e681dabb19d4ee0c9b2f26. Not docs-only: it changes a pinned dependency in CI, regenerated skills and a requirement in the live `agent-guidance` spec, so it went through OpenSpec and Woody's approval before apply.

**Target: `@fission-ai/openspec` 1.17.0.** The change was first proposed for 1.16.1 (head `e4622f6`). On the day of apply, task 1.2 found npm `latest` had moved to 1.17.0, so apply stopped and Woody chose to retarget (see Approval).

**Why the name still says `1-16-1`.** The change keeps the name `update-template-openspec-1-16-1` on purpose. Issue #30, the branch `30-update-template-openspec-1-16-1`, the commits, the Notion row and both approval records already point at this name. The OpenSpec CLI has no rename command, so renaming would mean moving the folder by hand and leaving those records pointing at a folder that no longer exists, and the branch name cannot change without a new branch. Keeping the name keeps every link valid; this paragraph, the issue title and the pull request title carry the real target, 1.17.0.

## Approval

| What | Words or selected option text | How given, where and when |
| --- | --- | --- |
| Keep the template's OpenSpec and Ponytail current (the request behind this change) | Typed by Woody: "in reference to the template repo I set up I wanna make sure those always have the current version of ponytail and open spec so can you check GitHub once a week to see if they are current and if not get those updated so that template always stays current" | Typed in Woody's chat with Chief of Staff, 2026-11-03 8:46 AM AZ. Relayed by Chief of Staff to Principal Engineer at 2026-11-09 8:10 AM AZ as a drift finding from the weekly check. A request to update, not approval of this proposal |
| Approve the 1.16.1 proposal (SUPERSEDED by the two rows below) | Typed by Woody: "Do it. I thought I'd gave already approval for these things to be done. Did you finish this?" | Typed by Woody in his chat with Principal Engineer at 8:33 PM AZ Nov 9, 2026: "Do it. I thought I'd gave already approval for these things to be done. Did you finish this?" Covers: applying update-template-openspec-1-16-1 as proposed at head e4622f6 (including the new 'OpenSpec pin records agree' scenario), verify, archive as the last commit in the same PR, open the PR, Principal QA review. Not covered: merging, any other scope change. Superseded: task 1.2 then found npm `latest` at 1.17.0 and apply stopped before any pin changed |
| Retarget to 1.17.0 | Selected option: "Switch to 1.17.0, the latest" on the card "Which OpenSpec version should the template go to?" | Tapped by Woody in his chat with Principal Engineer at 8:36 PM AZ Nov 9, 2026. Card: "Which OpenSpec version should the template go to?" Choice: "Switch to 1.17.0, the latest". Covers: revising the proposal to target 1.17.0. Not covered: applying the revised proposal, merging |
| Apply the 1.17.0 revision | Typed by Woody: "You already have a standing OK for that for a ponytail or open spec updates" | Typed by Woody in his chat with Principal Engineer at 8:36 PM AZ Nov 9, 2026: "You already have a standing OK for that for a ponytail or open spec updates". Covers: applying the 1.17.0-revised proposal without another tap, verifying it, archiving it, opening the PR and getting QA review. Not covered: merging, which follows the existing rule (QA SHIP on the exact head, green CI, Woody/CoS) |

## Why

The template pins `@fission-ai/openspec` 1.16.0 (set by #28 / PR #29). Upstream has since released 1.16.1 (2026-11-06 5:44 PM AZ) and 1.17.0 (2026-11-09 4:46 PM AZ, npm `latest` since 4:48 PM AZ), so the template is two releases behind and Woody wants it kept current.

## What Changes

- Bump the OpenSpec pin from 1.16.0 to 1.17.0 in `.github/workflows/ci.yml` and in both `TEMPLATE_SOURCE.md` rows (Sources and Tool pins).
- Regenerate `.agents/skills/openspec-*/` with `openspec update` at 1.17.0. A run on a scratch copy of `origin/main` `e0cb3c2` changes exactly six lines, the `generatedBy` value in each of the six skills; no skill is added or removed.
- Change the `agent-guidance` requirement "Skills live in .agents/skills" so it names `openspec update` as the refresh path and adds a scenario that the skills' `generatedBy` stamp, the `ci.yml` install pin and both `TEMPLATE_SOURCE.md` rows name the same OpenSpec version. Today nothing in the specs checks that these four records agree, which is the drift the weekly check looks for. The delta names no version, so it is unchanged by the retarget.
- What changes upstream:
  - 1.16.1 ([release notes](https://github.com/Fission-AI/OpenSpec/releases/tag/v1.16.1)): closed `#` runs on headings are parsed like unclosed ones; `validate` fails and `archive` refuses a delta spec with an unrecognized requirement section (for example `## DEPRECATED Requirements`) instead of warning and dropping it; `openspec version --check` checks even with telemetry off or in CI; the standalone binary only offers releases whose files are attached on GitHub.
  - 1.17.0 ([release notes](https://github.com/Fission-AI/OpenSpec/releases/tag/v1.17.0)): `openspec update` upgrades a project made by any release since 0.12 in one run without `--force`, removing old OpenSpec files nobody edited and keeping edited ones; cleanup never touches files outside the project; `update` prints a notice that command files (`/opsx:*`) go away in OpenSpec 2.0 while a configured tool still gets them (this template uses skills only, so no notice); `openspec config set delivery skills` no longer deletes edited command files; the Windows PowerShell installer detects the CPU when none is reported.
  - No breaking change in either. `engines.node` stays `>=22.12.0`; license stays MIT.
- Every current spec passes `openspec validate --all --strict` at 1.17.0 (8 passed, 0 failed, checked on `e0cb3c2`).
- Ponytail is not touched: it stays at upstream `HEAD` `96608e078b2d5ea607c5c3b8b5a54d1c1fba6846` (`v5.3.3-1-g96608e0`), which is still current.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `agent-guidance`: "Skills live in .agents/skills" now says the skills are refreshed with `openspec update` at the pinned version, and gains a scenario that the OpenSpec version records agree.

## Impact

- `.github/workflows/ci.yml` (one line: the npm pin). The pull request edits a workflow file, so it runs its own copy of `qa-gate` and its body says "Workflow files changed: yes".
- `.agents/skills/openspec-*/SKILL.md` (generated, six `generatedBy` lines).
- `TEMPLATE_SOURCE.md` (two rows).
- `openspec/specs/agent-guidance/spec.md`, at archive.
- No `SOURCE.md` records the OpenSpec version (only the three Ponytail folders have one), and `README.md` and `AGENTS.md` name no OpenSpec version, so none of them change.
- No new dependency, account, spending, ruleset or setting change.
- Derived repositories pick up 1.17.0 only from the next template release. A derived repository whose own delta specs use a non-standard requirement section will now fail `validate` instead of passing with a warning. A derived repository that also configures a tool with command files will see the 2.0 notice from `openspec update`.
