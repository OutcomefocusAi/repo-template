# Design: update-template-deps-2026-11

## Context

See proposal.md for why. Today the template pins `@fission-ai/openspec@1.14.3` in `.github/workflows/ci.yml` and `TEMPLATE_SOURCE.md`, the six generated skills carry `generatedBy: "1.14.3"`, and the three Ponytail skills record `09c434ab73ca43761c5d8b0c5d341926c2fba710` (`v5.3.2-8-g09c434a`) in their `SOURCE.md` files and in `TEMPLATE_SOURCE.md`.

Facts checked on 2026-11-03 (re-checked in task 1.2; command output goes in this change's `evidence/` folder on apply):

- npm `@fission-ai/openspec` versions after 1.14.3: 1.15.0 (2026-10-24) and 1.16.0 (2026-10-30, dist-tag `latest`). License MIT. 1.16.0 declares `engines.node >=22.12.0`.
- Release notes: 1.15.0 adds a standalone binary install and `openspec update --dry-run`, with no breaking change. 1.16.0 is breaking only for npm installs on Node older than 22.12.0, and makes `validate --strict` fail on a scenario without a WHEN/GIVEN or THEN step and on an unreadable `openspec/config.yaml`.
- `openspec update` at 1.16.0 on a scratch copy of `origin/main` `f1d0034`: `--dry-run` lists the six `.agents/skills/openspec-*/SKILL.md` files, and the real run changes one line in each (`generatedBy: "1.14.3"` to `"1.16.0"`), adds no file and adds no em dash.
- `openspec validate --all --strict` at 1.16.0 on `f1d0034`: 8 passed, 0 failed.
- Ponytail: `v5.3.3` is `7801d061243d7b753bad0e0b3c057cd250b11755` (`chore: release v5.3.3`); upstream `HEAD` `96608e078b2d5ea607c5c3b8b5a54d1c1fba6846` (`v5.3.3-1-g96608e0`) is one commit after it and six after `09c434a`. All six commits are `fix(band)` changes, the release commit and a README entry; none touches `skills/` or `LICENSE`. SHA-256 at all three commits:
  - `skills/ponytail/SKILL.md` `9badd22a32e19cb884e46dfa8d3aae82bb81dfa5484105b8b4f0262df823a509`
  - `skills/ponytail-review/SKILL.md` `33fe4ebe22a460924e5d4a261e223df22e409cc94ab76182bee9fb91a3ef022e`
  - `skills/ponytail-audit/SKILL.md` `2b3223a02c386d1263e1b08343cb8eb3a53e444cdafb1d79e26c8ec2a8fcad28`
  - `LICENSE` `fb1bc6909ac3ef82d5c22106e32ef682b0cff66788fa915fb9b53b15c9d2f3ab` (MIT)

## Goals / Non-Goals

**Goals:**
- Template pins OpenSpec 1.16.0 and Ponytail v5.3.3, with generated and vendored files matching those versions exactly.
- Each pin is recorded with a fingerprint a reviewer can recheck.

**Non-Goals:**
- The weekly currency check. Chief of Staff runs it as a routine and sends drift here as a new change; this repository gets no new workflow, Dependabot ecosystem or scheduled job for it.
- Switching CI to the OpenSpec standalone binary (`curl | sh` from openspec.dev). npm with an exact version stays the install path.
- Enabling the extra OpenSpec workflows `openspec update` mentions (new, continue, ff, bulk-archive, verify, onboard), or any change to `AGENTS.md`, the gitleaks or actionlint pins, or Node.js.

## Decisions

1. **OpenSpec 1.16.0, not 1.15.0.** 1.16.0 is npm `latest`; its only breaking change (Node 22.12.0 floor for npm installs) is already met by CI's Node 24.22.1, and its stricter validation passes every current spec. Stopping at 1.15.0 would leave the template a release behind for no gain.
2. **Ponytail v5.3.3 (`7801d06`), not `HEAD` (`96608e0`).** Default to the latest release; `HEAD` adds only a README line and no fix the skills need. The vendored files are byte-identical either way, so a release tag gives a stable, nameable pin with no content difference.
3. **Regenerate with `openspec update`, not `openspec init --tools agents`.** `update` refreshes the existing tool's skills in place, and the scratch run shows it produces exactly the version-stamp change. If the real run adds, removes or changes anything beyond the six `generatedBy` lines, stop and report before committing.
4. **Re-vendor by copying from upstream at `7801d06`** (`git show 7801d06:<path> > <dest>`) even though the bytes do not change, then record SHA-256 of `SKILL.md` and `LICENSE` in each `SOURCE.md`. Adding the `LICENSE` fingerprint makes both vendored files checkable.
5. **Spec delta.** The current scenario compares vendored copies with openspec-sandbox, which keeps the old pin and is not the source. The modified requirement makes upstream at the recorded commit, plus the recorded SHA-256 values, the reference. The other pin requirements ("Skills live in .agents/skills", "Third-party tools are pinned and license-checked") already speak of "the pinned version" and need no text change.

## Verification plan

- Local: install `@fission-ai/openspec@1.16.0` to a temporary prefix, run `openspec --version`, `openspec update`, then `git diff` shows only the six `generatedBy` lines; `openspec validate --all --strict` passes at 1.16.0.
- Ponytail: `sha256sum` of each vendored `SKILL.md` and `LICENSE` equals the same file from `git show 7801d06:...` and the values in its `SOURCE.md`; `TEMPLATE_SOURCE.md` and each `SOURCE.md` name `7801d061243d7b753bad0e0b3c057cd250b11755` and `v5.3.3`.
- Repository checks: `scripts/test-template-scripts.sh`, `scripts/check-em-dash.sh`, `scripts/check-workflows.sh`, actionlint, gitleaks full history, `scripts/check-commits.sh` and `git diff --check`.
- CI: `template-checks` installs 1.16.0 from the bumped line and its log shows the version; `project` green; then Principal QA review and `qa-gate`.
- `rg -n "1\.14\.3|09c434a"` outside `openspec/changes/archive/` finds nothing.

## Risks / Trade-offs

- [1.16.0 strict validation is tighter] → Already checked: all current specs pass. A derived repository with its own specs may need a WHEN/THEN fix after adopting the template release; note it in the PR.
- [Derived repositories on Node 20 using npm] → Release note in the PR and `TEMPLATE_SOURCE.md` names Node 22.12.0 as the floor; CI is on 24.22.1.
- [Transitive npm dependencies use caret ranges] → Unchanged from today; only the top-level package is exact. gitleaks and CI run on every push.
- [Workflow file edit] → The pull request runs its own `qa-gate` copy; QA checks the one-line diff in `ci.yml`.

## Migration Plan

Apply on the issue branch, one commit per task group, archive as the last commit, then QA and Woody's merge. Rollback: revert the squash-merge commit on `main` (restores 1.14.3, the `09c434a` records and the old spec text); no data or settings to migrate.
