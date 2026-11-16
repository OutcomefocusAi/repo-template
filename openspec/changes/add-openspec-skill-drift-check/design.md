# Design: add-openspec-skill-drift-check

## Context

See proposal.md for why. Today `template-checks` in `.github/workflows/ci.yml` installs `@fission-ai/openspec@2.0.0` with `npm install --global`, runs the self-tests, then `check-em-dash.sh`, `check-openspec-pin.sh` and `check-ponytail-pin.sh`. Nothing compares the generated skills with what OpenSpec generates.

Probes on 2026-11-16, OpenSpec 2.0.0, on a copy of `origin/main` `94df7b2`, each with a fresh temporary `XDG_CONFIG_HOME`:

| Case | `update --dry-run --json` | real `update` | `init --tools agents --profile core` |
| --- | --- | --- | --- |
| clean tree | only change listed: add `<tmp>/openspec/config.json` (global config, outside the repo) | no repo change | no repo change |
| one skill's text edited | lists that file, note code `edited-skills` | restores it | restores it |
| whole `openspec-explore/` folder deleted | not reported | not restored | restores it |
| one `SKILL.md` deleted, folder kept | not run | restores it | not run |
| `generatedBy` stamp edited | not run | restores it | not run |
| extra `openspec-extra/SKILL.md` or extra file in a skill folder | not reported | not run | left in place |
| `openspec/config.yaml` edited | not reported | not run | not run |

A fresh `openspec init --tools agents` in an empty git repository writes `.agents/skills/.openspec-target`, the six `.agents/skills/openspec-*/SKILL.md`, `openspec/config.yaml` and two `.gitkeep` files. Its `.agents/skills/` (without Ponytail) is byte-identical to `main`, and so is its `config.yaml`.

## Goals / Non-Goals

**Goals:**
- CI fails, with a file-level annotation and the fix, whenever the committed generated skill files are not exactly what the pinned OpenSpec version generates.
- The check is read-only for the checkout and for the user's global OpenSpec config.
- Self-tests cover every failure kind without network access.

**Non-Goals:**
- `openspec/config.yaml` and the `.gitkeep` files; vendored Ponytail files (already fingerprinted by `check-ponytail-pin.sh`); other profiles or tools.
- #34 N1, N3, N4, N5 (self-test gaps and scanner gaps in the pin checks). N2 becomes caught by this check, but #34 stays open for the rest.
- Running OpenSpec through `npx` in CI or adding any new download.

## Decisions

1. **Compare against a fresh `init`, not `update --dry-run` or `update` plus `git diff`.** The probes show `update --dry-run` misses a deleted skill folder and extra files, and a real `update` does not restore a deleted folder. `init --tools agents --profile core` in an empty temporary directory produces the full expected set, so a plain file-list and byte comparison catches edits, deletions, additions and untracked files in one pass. Alternative considered: `openspec update` in a copy of the checkout followed by `git diff --exit-code`; rejected because it misses deleted folders and extra files, the exact silent failures Woody asked to remove.
2. **Version from the CI pin, CLI verified.** The script reads the single version in the `@fission-ai/openspec@<version>` line of `.github/workflows/ci.yml` (the same reference `check-openspec-pin.sh` uses) and runs `openspec --version`; a mismatch is an error, never a fallback. The command defaults to `openspec` and can be overridden with `OPENSPEC_CMD` (for example `npx -y @fission-ai/openspec@2.0.0` locally, or a stub in the self-tests).
3. **Read-only by construction.** The reference is generated with `cd "$(mktemp -d)"`, `git init`, and `XDG_CONFIG_HOME`, `OPENSPEC_TELEMETRY=0` and `OPENSPEC_NO_UPDATE_CHECK=1` set only for that command; a `trap` removes the temporary directories. The checkout is only read (`find`, `cmp`, `git ls-files`). A self-test asserts `git status --porcelain --untracked-files=all` is unchanged and that the stub's marker file never appears in the checkout.
4. **What is compared.** `.agents/skills/.openspec-target` and every file under `.agents/skills/openspec-*/`, found with `find` so untracked files count; `git ls-files --others --exclude-standard` marks which extras are untracked, so the message can say so. Files are compared with `cmp`; differences are reported as edited, missing, extra or untracked, sorted by path, one annotation each.
5. **Separate script, not part of `check-openspec-pin.sh`.** The pin check needs no CLI and stays fast and offline; the new check needs the pinned CLI. Keeping them apart keeps one CI step and log line per concern, as `add-openspec-pin-check` did. A stamp edit fails both, which is fine.
6. **Fix text.** Edited: run `npx -y @fission-ai/openspec@<pin> update` and commit, or `git checkout -- <path>`. Missing: run `npx -y @fission-ai/openspec@<pin> init --tools agents --profile core` and commit, or `git checkout -- <path>` (the probes show `update` does not restore a deleted folder). Extra or untracked: delete it, or keep a custom skill under a name that does not start with `openspec-`. CLI version wrong or missing: `npm install --global @fission-ai/openspec@<pin>` or set `OPENSPEC_CMD`.
7. **Tests first, hermetic.** The self-tests put a stub `openspec` on `PATH` that answers `--version` with a configurable version and, for `init`, copies the generated files from the template's own committed tree and writes a marker file in its working directory. They are committed failing (the script does not exist yet) before the script.

## Risks / Trade-offs

- [OpenSpec changes what `init` writes in a later release] → The version bump change regenerates the skills; the check then names any file still different, which is intended.
- [`init` needs the network or prompts in a later release] → Self-tests use a stub, so only the real CI step would see it; it fails rather than passes. Re-checked at every OpenSpec bump.
- [Local runs without the pinned CLI] → Fails with the install command and the `OPENSPEC_CMD` override, never skips.
- [Derived repositories with another profile or tools] → They change the script's profile or tools in their own proposal; noted in `TEMPLATE_SOURCE.md`.
- [Workflow file edit] → The pull request runs its own `qa-gate` copy; one new `run:` step, checked by `check-workflows.sh` and actionlint.

## Migration Plan

Apply on the issue branch: approval record, failing self-tests, script, CI step and docs, checks, archive as the last commit before QA. Rollback: revert the squash-merge commit; nothing to migrate.
