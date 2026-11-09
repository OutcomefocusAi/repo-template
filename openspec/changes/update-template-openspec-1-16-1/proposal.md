# Proposal: update-template-openspec-1-16-1

Tracking issue: [#30](https://github.com/OutcomefocusAi/repo-template/issues/30). Branch: `30-update-template-openspec-1-16-1`. Notion Tasks row: https://app.notion.com/p/413444b092e681dabb19d4ee0c9b2f26. Not docs-only: it changes a pinned dependency in CI, regenerated skills and a requirement in the live `agent-guidance` spec, so it goes through OpenSpec and waits for Woody's approval before apply.

## Approval

| What | Words or selected option text | How given, where and when |
| --- | --- | --- |
| Keep the template's OpenSpec and Ponytail current (the request behind this change) | Typed by Woody: "in reference to the template repo I set up I wanna make sure those always have the current version of ponytail and open spec so can you check GitHub once a week to see if they are current and if not get those updated so that template always stays current" | Typed in Woody's chat with Chief of Staff, 2026-11-03 8:46 AM AZ. Relayed by Chief of Staff to Principal Engineer at 2026-11-09 8:10 AM AZ as a drift finding from the weekly check. A request to update, not approval of this proposal |
| Approve this proposal | Pending | Approval to apply: pending Woody's tap in his chat with Chief of Staff. Task 1.1 records the card, the choice, and what it covers before any other task starts |

## Why

The template pins `@fission-ai/openspec` 1.16.0 (set by #28 / PR #29). Upstream released 1.16.1 on 2026-11-06 5:44 PM AZ (npm `latest` since 2026-11-06 5:46 PM AZ), so the template is one patch release behind and Woody wants it kept current.

## What Changes

- Bump the OpenSpec pin from 1.16.0 to 1.16.1 in `.github/workflows/ci.yml` and in both `TEMPLATE_SOURCE.md` rows (Sources and Tool pins).
- Regenerate `.agents/skills/openspec-*/` with `openspec update` at 1.16.1. A run on a scratch copy of `origin/main` `e0cb3c2` changes exactly six lines, the `generatedBy` value in each of the six skills; no skill is added or removed.
- Change the `agent-guidance` requirement "Skills live in .agents/skills" so it names `openspec update` as the refresh path and adds a scenario that the skills' `generatedBy` stamp, the `ci.yml` install pin and both `TEMPLATE_SOURCE.md` rows name the same OpenSpec version. Today nothing in the specs checks that these four records agree, which is the drift this weekly check looks for.
- What 1.16.1 changes upstream ([release notes](https://github.com/Fission-AI/OpenSpec/releases/tag/v1.16.1)): closed `#` runs on headings are parsed like unclosed ones; `validate` fails and `archive` refuses a delta spec with an unrecognized requirement section (for example `## DEPRECATED Requirements`) instead of warning and dropping it; `openspec version --check` checks even with telemetry off or in CI; the standalone binary only offers releases whose files are attached on GitHub. No breaking change. `engines.node` stays `>=22.12.0`; license stays MIT.
- Every current spec passes `openspec validate --all --strict` at 1.16.1 (8 passed, 0 failed, checked on `e0cb3c2`).
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
- Derived repositories pick up 1.16.1 only from the next template release. A derived repository whose own delta specs use a non-standard requirement section will now fail `validate` instead of passing with a warning.
