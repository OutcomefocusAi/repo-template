# Proposal: add-openspec-pin-check

Tracking issue: [#32](https://github.com/OutcomefocusAi/repo-template/issues/32) (filed by Principal QA in the review of PR #31). Branch: `32-add-openspec-pin-check`, from `main` `52e24f9c6b94684f180aa2f3ee1b0e5c26380a3c` (OpenSpec 1.17.0). Notion Tasks row: https://app.notion.com/p/414444b092e681938765eddabecff170. Not docs-only: it adds two scripts and two CI steps and changes the live `continuous-integration` spec.

**Scope extension.** The proposal at `c4825ab` covered the OpenSpec records only and recommended a Ponytail check as a separate follow-up. Woody approved it with the Ponytail pin check added (see Approval), so this revision adds it to the same change.

## Approval

| What | Words or selected option text | How given, where and when |
| --- | --- | --- |
| Build the check in #32 (the request behind this change) | Selected option: "Yes, build the automated version check in issue #32." | Tapped by Woody in his chat with Chief of Staff at 9:14 PM AZ Nov 9, 2026, relayed by Chief of Staff. Covers: building this check through the usual flow. Not covered: applying this proposal before Woody approves it, merging (this adds CI behavior, so the merge comes back to Woody) |
| Approve this proposal, extended with a Ponytail pin check | Selected option: "Yes, and add the Ponytail pin check too." on the card "Approve add-openspec-pin-check (issue #32, head c4825ab)?" | Tapped by Woody in his chat with Chief of Staff at 9:19 PM AZ Nov 9, 2026 (relayed by CoS). Card: "Approve add-openspec-pin-check (issue #32, head c4825ab)?" Choice: "Yes, and add the Ponytail pin check too." Covers: approving add-openspec-pin-check at c4825ab, extending scope to a Ponytail pin agreement check, then apply, verify, archive as last commit, PR with Closes #32, QA review. Not covered: merging (comes back to Woody), any other scope. |

## Why

Nine records name the template's OpenSpec version: the `generatedBy` stamp in each of the six `.agents/skills/openspec-*/SKILL.md`, the `@fission-ai/openspec@<version>` install line in `.github/workflows/ci.yml`, and the OpenSpec rows in the Sources and Tool pins tables of `TEMPLATE_SOURCE.md`. The `agent-guidance` scenario "OpenSpec pin records agree" says they must name the same version, but only a reviewer checks it. Principal QA showed in the PR #31 review that a tree with one record changed still passes every CI step. With weekly version bumps now merging under a standing OK, a missed record should fail CI instead of relying on review.

The vendored Ponytail skills have the same gap. Four records name the pinned upstream commit (each of the three `.agents/skills/ponytail*/SOURCE.md` files and the Ponytail row of `TEMPLATE_SOURCE.md`), and each `SOURCE.md` records the SHA-256 of its `SKILL.md` and `LICENSE`. The `agent-guidance` requirement "Ponytail skills are vendored at a pinned commit" says these agree, but again only a reviewer checks it.

## What Changes

- New script `scripts/check-openspec-pin.sh` (Bash glue, same style as `check-workflows.sh`): reads the nine records, fails with a `::error file=...,line=...` annotation for each record that is missing, appears twice, is not an exact `MAJOR.MINOR.PATCH`, or disagrees with the others, and prints `check-openspec-pin: 9 records agree on <version>` on success. It names no version itself, so later bumps need no script change.
- `scripts/test-template-scripts.sh` gains self-test cases with fixtures: the real tree passes; a consistent older version passes; one `TEMPLATE_SOURCE.md` row changed, one `generatedBy` changed, the CI pin moved to a third version, a range pin (`^1.17.0`), a missing Tool pins row and a skill without a stamp each fail.
- New script `scripts/check-ponytail-pin.sh`, same style: for every `.agents/skills/ponytail*/` folder it reads `SOURCE.md` and fails, with a `::error` per finding, unless the "Pinned commit" is a full 40-character SHA, the "File at that commit" link uses the same SHA, the `git describe` string and the commit match the Ponytail row of `TEMPLATE_SOURCE.md`, and the recorded SHA-256 of `SKILL.md` and `LICENSE` match the files on disk. On success it prints `check-ponytail-pin: 3 skill(s) agree on <commit> (<describe>)`.
- Self-test cases for the Ponytail script: the real tree passes; one `SOURCE.md` commit changed, the `TEMPLATE_SOURCE.md` row commit changed, the describe string changed in one place, the link SHA changed, an edited `SKILL.md`, a short SHA, a missing `SOURCE.md` and a missing `TEMPLATE_SOURCE.md` row each fail.
- `.github/workflows/ci.yml` `template-checks` runs the two scripts as new steps, "OpenSpec pin agreement" and "Ponytail pin agreement", right after the em-dash check.
- One sentence under the Tool pins table in `TEMPLATE_SOURCE.md` says CI checks that the OpenSpec records agree and that the Ponytail records agree and match the vendored files, so whoever bumps a pin knows which records move together.
- The `continuous-integration` requirement "Template checks always run" lists both checks and gains four scenarios (OpenSpec records disagree; OpenSpec record missing or not exact; Ponytail commit or describe records disagree or a record is missing; vendored file does not match its recorded SHA-256).

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `continuous-integration`: "Template checks always run" adds the OpenSpec and Ponytail pin agreement checks to the checks run on every CI run, with scenarios for disagreement, for a missing or non-exact record, and for a vendored Ponytail file that no longer matches its recorded SHA-256.

## Impact

- New `scripts/check-openspec-pin.sh` and `scripts/check-ponytail-pin.sh`; `scripts/test-template-scripts.sh`; `.github/workflows/ci.yml` (two new steps); `TEMPLATE_SOURCE.md` (one sentence, no pin change); `openspec/specs/continuous-integration/spec.md` at archive.
- The pull request edits a workflow file, so it runs its own copy of `qa-gate` and its body says "Workflow files changed: yes". The merge needs Woody's tap: this adds CI behavior and is not a version-only bump.
- `scripts/` and `.github/` are in `template-manifest.txt`, so derived repositories get the check from the next template release. A derived repository keeps the same records, so both checks apply there unchanged.
- No new dependency, account, spending, ruleset or setting change. No pin changes: Ponytail stays at `96608e078b2d5ea607c5c3b8b5a54d1c1fba6846` and OpenSpec at 1.17.0. `sha256sum` (GNU coreutils) is already on the `ubuntu-24.04` runner.
