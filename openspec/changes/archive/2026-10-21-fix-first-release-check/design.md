# Design

## Context

See proposal.md, Why. Facts the approach rests on, read from release-please 17.6.0 (the version the pinned action v5.0.0 runs):

- With no release found and a manifest version of `0.0.0`, the next version is `initial-version` (`1.0.0` when unset). With a manifest version other than `0.0.0` and no tag, release-please treats the manifest version as the latest release and bumps from it. So a derived repository that keeps the template's `0.1.0` manifest would propose `0.1.1` or `0.2.0` as its first release.
- The default versioning strategy bumps the major version for a breaking change even below `1.0.0` unless `bump-minor-pre-major` is true. A `Release-As:` footer forces an exact version.
- The first changelog heading is `## 0.1.0 (YYYY-MM-DD)`; later headings are `## [X.Y.Z](compare-url) (YYYY-MM-DD)`.
- `template-checks` runs `scripts/test-template-scripts.sh` on the merge ref of every pull request, including release pull requests, and on `main`.

## Goals / Non-Goals

**Goals:**
- One self-test check that passes in both states the repository can be in (before any release, and with an open or merged release) and fails when the version files disagree.
- No unintended `1.0.0`.
- Derived repositories start their own versions at `0.1.0`.

**Non-Goals:**
- Changing release.yml, qa-gate, the release auto-pass rule, permissions, rulesets or settings.
- Touching PR #11, tagging, or publishing anything.
- Running release-please against the live repository in CI (the check stays static and offline).

## Decisions

1. **State-aware static check instead of a fixed `0.0.0` assertion.** Read `initial-version`, the manifest, `version.txt` and the newest `## ` version heading in `CHANGELOG.md`. Always require `initial-version` = `0.1.0` (it is inert after the first release and keeps derived repositories correct). Require manifest = `version.txt`, both `MAJOR.MINOR.PATCH`. If they are `0.0.0`, require that `CHANGELOG.md` is absent or has no version heading; otherwise require the newest heading to equal them. Alternative considered: skip the check on release branches. Rejected: it would still fail on `main` after the release merges and would hide real drift.
2. **`bump-minor-pre-major: true`.** Keeps `0.x` for breaking changes until someone adds `Release-As: 1.0.0` on purpose. Alternative: leave the default and rely on reviewers to spot `!` commits. Rejected: the jump is silent in the release pull request title only, and qa-gate auto-passes release pull requests.
3. **README reset step for derived repositories**, not a script. It is three file edits done once, next to the existing `TEMPLATE_SOURCE.md` step. Alternative: have the check compare against `TEMPLATE_SOURCE.md`. Rejected as more machinery than the risk needs.
4. **Failing test first.** Add the new cases to the self-test (fixtures for: pre-release, release `0.1.0`, later release `0.2.0` with a linked heading, manifest and `version.txt` disagree, heading disagrees, missing `bump-minor-pre-major`) and show that the current check fails the release cases before changing it.
5. **Behavior check with the pinned release-please.** Run release-please 17.6.0 offline (its version-calculation code, no GitHub calls) to confirm: `feat!:` on `0.1.0` with the new config gives `0.2.0`, and `Release-As: 1.0.0` gives `1.0.0`. Record the output as evidence in the change folder.

## Risks / Trade-offs

- [A derived repository skips the README reset] → the check still passes (its files agree), and its first release is not `0.1.0`. Mitigation: the README step and its scenario; QA follows the README on a scratch copy.
- [release-please changes its heading format in a later version] → the heading parse fails loudly in the self-test, which is the wanted signal; Dependabot bumps of the action go through CI.
- [The `fix:` commit for this change lands before #11 merges] → release-please rebuilds #11 and lists it under 0.1.0 Bug Fixes. Expected and harmless.

## Migration Plan

Merge after Principal QA's SHIP and Woody's OK. The next push to `main` rebuilds release PR #11; after "Approve workflows to run" its `template-checks` should pass. Rollback: revert the squash commit; #11 then fails `template-checks` again as it does now.
