# Proposal: update-effort-rule

Tracking issue: [#26](https://github.com/OutcomefocusAi/repo-template/issues/26). Branch: `26-update-effort-rule`. Notion Tasks row: TBD. Not docs-only: it changes a requirement in the live `agent-guidance` spec, so it goes through OpenSpec and waits for Woody's approval before apply.

## Approval

| What | Words or selected option text | How given, where and when |
| --- | --- | --- |
| Normal effort for docs work (the rule this change writes down) | Option selected by Woody: "Merge paperwork into the main PR and use normal effort for docs work" (answering "Which of these should I change?") | Option selected in Woody's chat with Chief of Staff, 2026-10-21 5:05 PM MST; relayed verbatim to Principal Engineer. Covers normal effort for docs-only work, archive work and routine CI or status checks; code, feature and release work stays at highest effort; all other gates unchanged |
| Propose this spec change | Option selected by Woody: "Yes, propose the small spec change for the effort rule." (answering "Update the template's written effort rule to match?") | Option selected in Woody's chat with Chief of Staff, 2026-10-21 8:03 PM MST; relayed verbatim to Principal Engineer. A request to propose, not approval of this proposal; does not cover applying, merging, or any other spec change |
| Approve this proposal | Pending | Not yet given. No apply task starts until it is recorded here |

## Why

The `agent-guidance` requirement "AGENTS.md states the maximum effort rule" and `AGENTS.md` section 12 require the highest effort or reasoning level for all work and for every delegated worker. Woody has since chosen normal effort for docs-only work, OpenSpec archive work and routine CI or status checks, keeping the highest level for code, features, releases and the rest. The written rule no longer matches the owner's rule, so agents following `AGENTS.md` would either break the written rule or ignore the owner's choice.

## What Changes

- Rename the requirement "AGENTS.md states the maximum effort rule" to "AGENTS.md states the effort rule".
- Modify it: the highest effort or reasoning level stays required for code, features, releases, design, debugging, testing, review and verification work, including independent QA of any change and any delegated worker doing that work; normal effort is allowed for docs-only changes (section 9), OpenSpec archive work, and routine CI or status checks; when unsure which applies, use the highest level; every approval gate is unchanged.
- On apply (not in this proposal): rewrite `AGENTS.md` section 12 to match, keeping its no-spending paragraph unchanged.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `agent-guidance`: "AGENTS.md states the maximum effort rule" is renamed to "AGENTS.md states the effort rule" and its text and scenarios change as above.

## Impact

- `AGENTS.md` section 12 (wording and possibly its heading), on apply.
- `openspec/specs/agent-guidance/spec.md`, at archive.
- Derived repositories inherit the new rule. No code, configuration, CI, workflow, dependency, ruleset or setting change. No test or check asserts the effort wording today (searched the repository outside archived changes).
