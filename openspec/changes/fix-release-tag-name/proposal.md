# Proposal: fix-release-tag-name

Tracking issue: [#18](https://github.com/OutcomefocusAi/repo-template/issues/18). Branch: `18-fix-release-tag-name`. Notion Tasks row: https://app.notion.com/p/400444b092e68156a7b5da0ac8791f1a. Not docs-only: it changes release configuration, a test and a spec requirement, so it goes through OpenSpec and waits for Woody's approval before apply.

## Approval

| What | Words or selected option text | How given, where and when |
| --- | --- | --- |
| Hold release PR #11 and propose this fix | Option selected by Woody: "Hold release PR #11 and have Principal Engineer propose the small fix so the tag is v0.1.0." | Option selected in Woody's chat with Chief of Staff, 2026-10-21 4:06 PM MST; relayed verbatim to Principal Engineer. A request to propose, not approval of this proposal |
| Approve this proposal | Pending: not approved yet | Waiting for Woody |

## Why

`release-please-config.json` does not set `include-component-in-tag`, which release-please 17.6.0 defaults to true, so merging release PR #11 would create tag `repo-template-v0.1.0` and GitHub release `repo-template: v0.1.0`. The release-management spec says the tag is `vX.Y.Z`, and README tells derived repositories to use a tag such as `v0.1.0` with `gh api .../commits/<tag>` and `scripts/template-drift.sh <tag>`, which would not find the component tag. Principal QA found it in the pre-check of #11 and opened #18. The tag is what derived repositories pin to, so it has to be right before the first release is published.

## What Changes

- Add `"include-component-in-tag": false` to the root package in `release-please-config.json`, so tags and release names are `v<semver>` with no component prefix (`v0.1.0` for the first release).
- Extend the template self-test's release check to require that key to be the JSON boolean `false` (failing fixture first).
- Side effect, from the same setting in release-please 17.6.0: the release pull request title loses the component (`chore(main): release 0.1.0` instead of `chore(main): release repo-template 0.1.0`). The release branch name, the changelog headings, and the qa-gate release rule (which reads the branch, repository, author and files, not the title) are unchanged.
- Release PR #11 is not touched by this change. When it merges, release-please rebuilds #11 on the next push to `main`; its checks run again after "Approve workflows to run" and are re-checked before Woody merges it.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `release-management`: "Tags only on merging the release pull request" states that the tag and the GitHub release name are `v<semver>` with no component prefix, with scenarios for the first release (`v0.1.0`) and for the release name matching the tag.

## Impact

- `release-please-config.json` (one key), `scripts/test-template-scripts.sh` (release check and one fixture).
- The release pull request title format; the first tag and release (`v0.1.0`) when #11 merges.
- Derived repositories inherit the config, so their tags are `v<semver>` too, whatever their `package-name`.
- No workflow, permission, ruleset or setting change. No tag or release is created by this change.
