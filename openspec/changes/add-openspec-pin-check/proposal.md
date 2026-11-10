# Proposal: add-openspec-pin-check

Tracking issue: [#32](https://github.com/OutcomefocusAi/repo-template/issues/32) (filed by Principal QA in the review of PR #31). Branch: `32-add-openspec-pin-check`, from `main` `52e24f9c6b94684f180aa2f3ee1b0e5c26380a3c` (OpenSpec 1.17.0). Notion Tasks row: https://app.notion.com/p/414444b092e681938765eddabecff170. Not docs-only: it adds a script and a CI step and changes the live `continuous-integration` spec.

## Approval

| What | Words or selected option text | How given, where and when |
| --- | --- | --- |
| Build the check in #32 (the request behind this change) | Selected option: "Yes, build the automated version check in issue #32." | Tapped by Woody in his chat with Chief of Staff at 9:14 PM AZ Nov 9, 2026, relayed by Chief of Staff. Covers: building this check through the usual flow. Not covered: applying this proposal before Woody approves it, merging (this adds CI behavior, so the merge comes back to Woody) |
| Approve this proposal | Pending | Pending: Woody's approve card, relayed by Chief of Staff |

## Why

Nine records name the template's OpenSpec version: the `generatedBy` stamp in each of the six `.agents/skills/openspec-*/SKILL.md`, the `@fission-ai/openspec@<version>` install line in `.github/workflows/ci.yml`, and the OpenSpec rows in the Sources and Tool pins tables of `TEMPLATE_SOURCE.md`. The `agent-guidance` scenario "OpenSpec pin records agree" says they must name the same version, but only a reviewer checks it. Principal QA showed in the PR #31 review that a tree with one record changed still passes every CI step. With weekly version bumps now merging under a standing OK, a missed record should fail CI instead of relying on review.

## What Changes

- New script `scripts/check-openspec-pin.sh` (Bash glue, same style as `check-workflows.sh`): reads the nine records, fails with a `::error file=...,line=...` annotation for each record that is missing, appears twice, is not an exact `MAJOR.MINOR.PATCH`, or disagrees with the others, and prints `check-openspec-pin: 9 records agree on <version>` on success. It names no version itself, so later bumps need no script change.
- `scripts/test-template-scripts.sh` gains self-test cases with fixtures: the real tree passes; a consistent older version passes; one `TEMPLATE_SOURCE.md` row changed, one `generatedBy` changed, the CI pin moved to a third version, a range pin (`^1.17.0`), a missing Tool pins row and a skill without a stamp each fail.
- `.github/workflows/ci.yml` `template-checks` runs the script as a new step, "OpenSpec pin agreement", right after the em-dash check.
- One sentence under the Tool pins table in `TEMPLATE_SOURCE.md` says CI checks the OpenSpec records agree, so whoever bumps the pin knows all nine move together.
- The `continuous-integration` requirement "Template checks always run" lists the new check and gains two scenarios (records disagree, record missing or not exact).

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `continuous-integration`: "Template checks always run" adds the OpenSpec pin agreement check to the checks run on every CI run, with scenarios for disagreement and for a missing or non-exact record.

## Impact

- New `scripts/check-openspec-pin.sh`; `scripts/test-template-scripts.sh`; `.github/workflows/ci.yml` (one new step); `TEMPLATE_SOURCE.md` (one sentence, no pin change); `openspec/specs/continuous-integration/spec.md` at archive.
- The pull request edits a workflow file, so it runs its own copy of `qa-gate` and its body says "Workflow files changed: yes". The merge needs Woody's tap: this adds CI behavior and is not a version-only bump.
- `scripts/` and `.github/` are in `template-manifest.txt`, so derived repositories get the check from the next template release. A derived repository keeps the same nine records, so the check applies there unchanged.
- No new dependency, account, spending, ruleset or setting change. Ponytail and all pins stay as they are.
