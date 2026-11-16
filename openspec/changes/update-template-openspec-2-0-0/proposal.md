# Proposal: update-template-openspec-2-0-0

Tracking issue: [#35](https://github.com/OutcomefocusAi/repo-template/issues/35). Branch: `35-update-template-openspec-2-0-0`, from `main` `8c529c4428f67672bbfb59f73e3ff29514e4f827` (OpenSpec 1.17.0). Notion Tasks row: https://app.notion.com/p/41a444b092e681e7ad82d54e5e82e5e1. Not docs-only and not covered by the standing OK for version-only bumps: OpenSpec 2.0.0 is a major release and its `openspec update` changes the instruction text of all six generated skills, not just their version stamp, so it needs Woody's approval of this proposal before apply.

## Approval

| What | Words or selected option text | How given, where and when |
| --- | --- | --- |
| Keep the template's OpenSpec current (the request behind this change) | Typed by Woody: "in reference to the template repo I set up I wanna make sure those always have the current version of ponytail and open spec so can you check GitHub once a week to see if they are current and if not get those updated so that template always stays current" | Typed in Woody's chat with Chief of Staff, 2026-11-03 8:46 AM AZ. Relayed by Chief of Staff to Principal Engineer on 2026-11-16 as a drift finding from the weekly check (OpenSpec 1.17.0 pinned, npm `latest` 2.0.0). A request to update, not approval of this proposal |
| Approve this proposal | Pending | Not yet given. Apply does not start until Woody approves |

## Why

The template pins `@fission-ai/openspec` 1.17.0 (set by #30 / PR #31). Upstream released 2.0.0 on 2026-11-11 (npm publish 22:46 UTC, 3:46 PM AZ), now npm `latest`, so the template is one major release behind and Woody wants it kept current. The standing OK of Nov 9 covers only version pins, stamps and source records; 2.0.0 also rewrites skill instructions, so it comes through a proposal.

## What Changes

- Bump the OpenSpec pin from 1.17.0 to 2.0.0 in `.github/workflows/ci.yml` and in both `TEMPLATE_SOURCE.md` rows (Sources and Tool pins).
- Regenerate `.agents/skills/openspec-*/` with `openspec update` at 2.0.0. A run on a scratch copy of `origin/main` `8c529c4` modifies the same six `SKILL.md` files (35 lines changed each way) and adds, removes or moves no file:
  - the `generatedBy` stamp moves to `"2.0.0"`;
  - every reference to running a slash command (`/openspec-propose`, `/openspec-apply-change`, `/openspec-archive-change`, `/openspec-sync-specs`, `/openspec-update-change`, `/openspec-explore`) becomes the skill name (`openspec-propose`, or "use the `openspec-propose` skill");
  - the auto-selected and explicit-request rules say "invoked this skill by name" instead of "ran its slash command";
  - `openspec-update-change` says "recommended next skill" instead of "next command".
  Workflow steps, guardrails and planning boundaries are unchanged.
- Modify the `agent-guidance` requirement "Skills live in .agents/skills" with a scenario that the generated skills refer to OpenSpec workflows by skill name and no OpenSpec slash-command files exist in the repository. This is the behavior 2.0 introduces and it is checkable with one search.
- What changes upstream in 2.0.0:
  - [Release v2.0.0](https://github.com/Fission-AI/OpenSpec/releases/tag/v2.0.0), [CHANGELOG at v2.0.0](https://github.com/Fission-AI/OpenSpec/blob/v2.0.0/CHANGELOG.md), [Upgrade to 2.0](https://openspec.dev/docs/upgrade-to-2), [npm 2.0.0](https://www.npmjs.com/package/@fission-ai/openspec/v/2.0.0).
  - **BREAKING (upstream)**: skills only, written once to `.agents/skills/` with links for tools that read only their own folder; `/opsx:*` command files are no longer generated and `openspec update` removes unedited ones; the `delivery` setting is retired (still accepted, no effect); Amazon Q Developer support is removed.
  - Fixes: `openspec instructions apply` keeps a task that wraps onto several lines in `tasks.md`; Windows `completion install` from cmd.exe no longer edits PowerShell profiles.
  - Unchanged: `engines.node` stays `>=22.12.0`; license MIT; `openspec --help` output is identical to 1.17.0; `openspec init --tools agents` is still accepted; no change to `validate`, the spec or delta format, or the `openspec/` layout.
- Assessment on the scratch copy (2026-11-16): `openspec validate --all --strict` at 2.0.0 passed 8 of 8; with the pins hand-edited, `scripts/check-openspec-pin.sh` reported "9 records agree on 2.0.0"; `scripts/test-template-scripts.sh` passed 97 of 97; em-dash, Ponytail pin, workflow checks, actionlint and gitleaks passed.
- Ponytail is not touched: it stays at `96608e078b2d5ea607c5c3b8b5a54d1c1fba6846` (`v5.3.3-1-g96608e0`), still current.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `agent-guidance`: "Skills live in .agents/skills" gains a scenario that generated skills are invoked by name, with no OpenSpec slash-command files.

## Impact

- `.github/workflows/ci.yml` (one line: the npm pin). The pull request edits a workflow file, so it runs its own copy of `qa-gate` and its body says "Workflow files changed: yes".
- `.agents/skills/openspec-*/SKILL.md` (generated, six files, wording plus stamp as listed above).
- `TEMPLATE_SOURCE.md` (two rows).
- `openspec/specs/agent-guidance/spec.md`, at archive.
- No change to `AGENTS.md` (it names skills by path, never by slash command), `README.md`, `CLAUDE.md`, scripts, Node.js or `openspec/config.yaml`. `check-openspec-pin.sh` finds records by pattern and needs no change.
- No new dependency, account, spending, ruleset or setting change.
- Risks:
  - Agents or people who type `/openspec-propose` now read wording that says to invoke the skill by name. Tools that list skills as slash commands keep working; the text simply stops promising it.
  - Repositories already created from the template keep the 1.17.0 wording until they take the next template release and run `openspec update` at 2.0.0.
  - A derived repository that adds another tool (for example `--tools claude`) gets linked skill folders under 2.0; Windows checkouts need `core.symlinks` or get plain copies. The template itself configures only `agents`, so it has no links.
  - An edit inside `.agents/skills/openspec-*/` is overwritten by `openspec update`, as in 1.x. `AGENTS.md` already forbids editing them.
  - 2.0.0 is five days old at proposal time. Upstream says 1.x keeps working; rollback is a revert.
