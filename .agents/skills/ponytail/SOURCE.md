# Source of this vendored skill

This folder is a vendored copy of a third-party agent skill. Do not edit `SKILL.md` or `LICENSE` here. Local rules and overrides belong in the repo-root `AGENTS.md`, which takes precedence over this skill.

| Field | Value |
|-------|-------|
| Upstream repository | https://github.com/DietrichGebert/ponytail |
| Upstream path | `skills/ponytail/SKILL.md` |
| Pinned commit | `09c434ab73ca43761c5d8b0c5d341926c2fba710` |
| Upstream version | 5.3.2 (`git describe`: `v5.3.2-8-g09c434a`) |
| File at that commit | https://github.com/DietrichGebert/ponytail/blob/09c434ab73ca43761c5d8b0c5d341926c2fba710/skills/ponytail/SKILL.md |
| License | MIT, Copyright (c) 2026 DietrichGebert (see `LICENSE` in this folder) |
| Date vendored | 2026-10-21 |
| Modified | No. `SKILL.md` and `LICENSE` are byte-for-byte copies of the upstream files at the pinned commit. |
| SHA-256 of `SKILL.md` | `9badd22a32e19cb884e46dfa8d3aae82bb81dfa5484105b8b4f0262df823a509` |

## How to update

Updating this skill is its own OpenSpec change that needs owner approval:

1. Fetch upstream at the new commit SHA.
2. Diff the upstream `skills/ponytail/SKILL.md`, `skills/ponytail-review/SKILL.md`, and `skills/ponytail-audit/SKILL.md` against the vendored copies.
3. Check that nothing in the diff conflicts with the precedence rules in `AGENTS.md`.
4. Copy the files unchanged, along with `LICENSE`.
5. Update this file: pinned commit, upstream version, SHA-256, and date vendored.
