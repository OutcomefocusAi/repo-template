# Proposal: update-template-deps-2026-11

Tracking issue: [#28](https://github.com/OutcomefocusAi/repo-template/issues/28). Branch: `28-update-template-deps-2026-11`. Notion Tasks row: https://app.notion.com/p/40d444b092e681608b89e67034e3df6e. Not docs-only: it changes a pinned dependency in CI, regenerated skills and a requirement in the live `agent-guidance` spec, so it went through OpenSpec and waited for Woody's approval before apply.

## Approval

| What | Words or selected option text | How given, where and when |
| --- | --- | --- |
| Keep the template's OpenSpec and Ponytail current (the request behind this change) | Typed by Woody: "in reference to the template repo I set up I wanna make sure those always have the current version of ponytail and open spec so can you check GitHub once a week to see if they are current and if not get those updated so that template always stays current" | Typed in Woody's chat with Chief of Staff, 2026-11-03 8:46 AM MST; relayed verbatim to Principal Engineer. A request to update, not approval of this proposal. The weekly check is a routine on Chief of Staff's side, not part of this repository |
| Approve this proposal, with Ponytail pinned to upstream `HEAD` instead of v5.3.3 | Selected option: "Yes, but pin Ponytail to latest HEAD 96608e0 instead." on the card "Approve updating repo-template to OpenSpec 1.16.0 and Ponytail v5.3.3?" | Tapped by Woody in his chat with Chief of Staff at 2026-11-03 8:54 AM AZ. Card: 'Approve updating repo-template to OpenSpec 1.16.0 and Ponytail v5.3.3?'. Choice: 'Yes, but pin Ponytail to latest HEAD 96608e0 instead.' Covers: applying update-template-deps-2026-11 with OpenSpec 1.16.0 and Ponytail pinned to upstream HEAD 96608e0 instead of v5.3.3, then verifying, archiving in the same PR, and Principal QA review. Not covered: any other scope change, or merging. Relayed verbatim to Principal Engineer. This proposal was revised to the `HEAD` pin before any apply task |

## Why

The template pins `@fission-ai/openspec` 1.14.3 and vendors the Ponytail skills from `DietrichGebert/ponytail` at `09c434a` (`v5.3.2-8-g09c434a`). Upstream has since released OpenSpec 1.15.0 and 1.16.0 (npm `latest`, 2026-10-30) and Ponytail v5.3.3 (2026-10-29). Woody wants every repository started from the template to carry the current versions of both.

## What Changes

- Bump the OpenSpec pin from 1.14.3 to 1.16.0 in `.github/workflows/ci.yml` and `TEMPLATE_SOURCE.md`.
- Regenerate `.agents/skills/openspec-*/` with `openspec update` at 1.16.0. A dry run on a scratch copy changes exactly six lines, the `generatedBy` value in each of the six skills; no skill is added or removed.
- Re-pin the vendored `ponytail`, `ponytail-review` and `ponytail-audit` skills to upstream `HEAD` `96608e078b2d5ea607c5c3b8b5a54d1c1fba6846` (`v5.3.3-1-g96608e0`, one docs commit after the v5.3.3 release), copied byte for byte. Woody chose `HEAD` over the v5.3.3 release when approving (see Approval). Their `SKILL.md` and `LICENSE` files are byte-identical at `09c434a`, `v5.3.3` and upstream `HEAD` `96608e0`, so only each `SOURCE.md` and `TEMPLATE_SOURCE.md` change, with SHA-256 fingerprints for `SKILL.md` and `LICENSE`.
- Change the `agent-guidance` requirement "Ponytail skills are vendored at a pinned commit" so the vendored copies are checked against the upstream commit and fingerprints recorded in each `SOURCE.md`, not against the openspec-sandbox copies, which stay at the old pin.
- **BREAKING** (CI only, already met): OpenSpec 1.16.0 needs Node.js 22.12.0 or newer for npm installs. CI uses Node.js 24.22.1. A derived repository that installs OpenSpec with npm on Node 20 must upgrade Node or use the standalone binary.
- `openspec validate --strict` at 1.16.0 also fails a scenario without a WHEN/GIVEN or THEN step, and an unreadable `openspec/config.yaml`. Every current spec passes `openspec validate --all --strict` at 1.16.0 (checked on `origin/main` `f1d0034`).

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `agent-guidance`: "Ponytail skills are vendored at a pinned commit" now names the upstream commit and SHA-256 fingerprints in `SOURCE.md` as the reference for byte-for-byte copies, and its scenario checks against upstream instead of openspec-sandbox.

## Impact

- `.github/workflows/ci.yml` (one line: the npm pin). The pull request edits a workflow file, so it runs its own copy of `qa-gate` and its body says "Workflow files changed: yes".
- `.agents/skills/openspec-*/SKILL.md` (generated, six `generatedBy` lines).
- `.agents/skills/ponytail*/SOURCE.md` (three files) and `TEMPLATE_SOURCE.md`.
- `openspec/specs/agent-guidance/spec.md`, at archive.
- No new dependency, account, spending, ruleset or setting change. Licenses unchanged: OpenSpec MIT (npm `license` and `LICENSE` at 1.16.0), Ponytail MIT (`LICENSE` SHA-256 unchanged at v5.3.3 and `HEAD`).
- Derived repositories pick up the new versions only from the next template release; existing derived repositories are unchanged until they adopt it.
