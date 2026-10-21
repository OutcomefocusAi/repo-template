# Proposal: fix-first-release-check

Tracking issue: [#14](https://github.com/OutcomefocusAi/repo-template/issues/14). Branch: `14-fix-first-release-check`. Notion Tasks row: https://app.notion.com/p/400444b092e681328874f6bf9f282d5e. Not docs-only: it changes a test, release configuration and spec requirements, so it goes through OpenSpec and waits for Woody's approval before apply.

## Approval

| What | Words or selected option text | How given, where and when |
| --- | --- | --- |
| Approve this proposal (at `be539e8`, issue #14) | Option selected by Woody: "Yes, approve fix-first-release-check as proposed, including the under-1.0.0 rule and the README reset step." (answering "Approve the release check fix?") | Option selected on Chief of Staff's card in Woody's chat with Chief of Staff, 2026-10-21 3:29 PM MST; option text by Chief of Staff; relayed verbatim to Principal Engineer. Covers the proposal only; not a merge OK. Recorded here before apply |

## Why

The self-test added in #7 (commit `7c6e4d3`, `scripts/test-template-scripts.sh`) passes only while `.release-please-manifest.json` and `version.txt` both read `0.0.0`. The release pull request (#11) sets both to `0.1.0`, so `template-checks` fails on it ("FAIL release: first release would not be 0.1.0 (initial-version 0.1.0, manifest 0.1.0, version.txt 0.1.0)", CI run 39685594079), and it would fail on `main` after #11 merges. No spec scenario covers the first version: the check traces only to design D6 of `bootstrap-repo-template`. Separately, release-please 17.6.0 bumps a `0.x` version straight to `1.0.0` on any breaking-change commit unless `bump-minor-pre-major` is set, and a repository made from the template inherits the template's manifest, `version.txt` and `CHANGELOG.md`, so its first release would not be `0.1.0` either.

## What Changes

- Replace the self-test check with one that holds before and after the first release: `initial-version` is `0.1.0`; the manifest and `version.txt` agree and are valid versions; with `0.0.0` there is no released version in `CHANGELOG.md`; with any other version the newest `CHANGELOG.md` heading is that version.
- Set `"bump-minor-pre-major": true` in `release-please-config.json`, so a breaking change before `1.0.0` bumps the minor version; `1.0.0` comes only from a deliberate `Release-As: 1.0.0` commit footer. The self-test asserts the setting.
- README "start a new repository" steps: reset the release state (manifest and `version.txt` to `0.0.0`, delete the inherited `CHANGELOG.md`) so the derived repository's first release is `0.1.0`.
- Release PR #11 is not touched by this change. Once this merges, release-please rebuilds #11 on the next push to `main`; its checks then run again (after "Approve workflows to run") against the fixed test.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `release-management`: "Release pull request from Conventional Commits" gains scenarios for the first release (`0.1.0`), version consistency after a release, and no unintended jump to `1.0.0`.
- `template-lifecycle`: "README explains starting a new repository" adds resetting the inherited release state.

## Impact

- `scripts/test-template-scripts.sh` (the release check), `release-please-config.json` (one key), `README.md` (one step).
- CI job `template-checks` on `main`, on feature pull requests and on release pull requests.
- No workflow, permission, ruleset or setting change. No tag or release is created by this change.
