# Design

## Context

See proposal.md, Why. Facts from release-please 17.6.0 (`build/src/strategies/base.js`), the version the pinned action v5.0.0 runs:

- `includeComponentInTag` defaults to `true` (line 61). `getComponent()` returns `''` when it is false (lines 78 to 83), otherwise the normalized `package-name` (`repo-template`).
- On merge, the tag is `TagName(version, includeComponentInTag ? component : undefined, separator, includeVInTag)` and the release name is `"<component>: v<version>"` when a component is included, otherwise `"v<version>"` (lines 425 to 429).
- The release branch uses `getBranchComponent()`, which ignores `includeComponentInTag` (lines 88 to 90, 167 to 170), so the branch stays `release-please--branches--main--components--repo-template`.
- The release pull request title is built from `getComponent()`, so it drops the component.
- When looking for earlier releases, a tag matches only if it has no component while `includeComponentInTag` is false (`manifest.js` `tagMatchesConfig`). The repository has no tags yet, so nothing is orphaned.

Offline run (evidence/proposal-tag-probe.txt), config read through `Manifest.fromManifest`, manifest and body from #11's head `59f38a9`:

| | main today | with `"include-component-in-tag": false` |
| --- | --- | --- |
| Release branch | `release-please--branches--main--components--repo-template` | same |
| Release pull request title | `chore(main): release repo-template 0.1.0` | `chore(main): release 0.1.0` |
| Tag on merge | `repo-template-v0.1.0` | `v0.1.0` |
| GitHub release name | `repo-template: v0.1.0` | `v0.1.0` |

Merging a release pull request that still has the old title gives `v0.1.0` and `v0.1.0` with the new config as well.

## Goals / Non-Goals

**Goals:**
- First tag and release `v0.1.0`; every later tag and name `vX.Y.Z`.
- The self-test fails if the setting is missing or not the JSON boolean `false`.

**Non-Goals:**
- Changing release.yml, qa-gate, the release auto-pass rule, permissions, rulesets or settings.
- Touching PR #11, tagging, or publishing anything in this change.
- Renaming `package-name` (it still names the release branch and the changelog context).
- Updating README's stale "Release pull requests" paragraph about the Actions settings (separate docs change).

## Decisions

1. **`"include-component-in-tag": false` on the root package.** It is the setting release-please provides for single-package repositories and changes the tag and release name together. Alternative: change the spec and README to `repo-template-vX.Y.Z`. Rejected: derived repositories that keep the copied `package-name` would carry `repo-template-` in their own tags, and the README `<tag>` instructions would need a template-specific prefix.
2. **Self-test assertion in the existing `release_state` check**, same pattern as `bump-minor-pre-major`: read the key with jq, require the JSON boolean `false` (a string `"false"` or a missing key fails and is reported as found). A fixture with the key missing, and one with the string, must fail before the config changes (failing test first).
3. **Offline behavior check with the pinned release-please** after the fix, recorded in the change folder: tag and release name `v0.1.0`, branch unchanged.
4. **Re-check #11 after it rebuilds**: after this merges, release-please rebuilds #11 (new title, same files). Approve its workflow runs (Woody's 3:30 PM rule) and verify template-checks, project and qa-gate, and the title and files, before Woody's merge.

## Risks / Trade-offs

- [The release pull request title changes] → qa-gate's release rule does not read the title; the self-test does not either. Noted in the proposal.
- [Derived repositories] → they inherit `v<semver>` tags, which is what README describes. No change for them beyond the README reset step they already follow.
- [#11 rebuilds after 5:00 PM MST] → the changelog heading date is the UTC build date and would read 2026-10-22. Cosmetic; noted for the re-check.
- [A later release-please version changes the default or the key] → the self-test asserts the key, and Dependabot bumps of the action go through CI and QA.

## Migration Plan

Merge after Principal QA's SHIP and Woody's OK. The next push to `main` rebuilds #11; re-check it, then Woody merges #11, which creates tag `v0.1.0` and release `v0.1.0`. Rollback before #11 merges: revert the squash commit. After a tag exists, a wrong tag would have to be deleted by hand, which is why this lands first.
