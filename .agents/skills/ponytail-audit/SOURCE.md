# Source of this vendored skill

This folder is a vendored copy of a third-party agent skill. Do not edit `SKILL.md` or `LICENSE` here. Local rules and overrides belong in the repo-root `AGENTS.md`, which takes precedence over this skill.

| Field | Value |
|-------|-------|
| Upstream repository | https://github.com/DietrichGebert/ponytail |
| Upstream path | `skills/ponytail-audit/SKILL.md` |
| Pinned commit | `96608e078b2d5ea607c5c3b8b5a54d1c1fba6846` |
| Upstream version | 5.3.3 plus one docs commit (`git describe --tags`: `v5.3.3-1-g96608e0`) |
| File at that commit | https://github.com/DietrichGebert/ponytail/blob/96608e078b2d5ea607c5c3b8b5a54d1c1fba6846/skills/ponytail-audit/SKILL.md |
| License | MIT, Copyright (c) 2026 DietrichGebert (see `LICENSE` in this folder) |
| Date vendored | 2026-11-03 |
| Modified | No. `SKILL.md` and `LICENSE` are byte-for-byte copies of the upstream files at the pinned commit. |
| SHA-256 of `SKILL.md` | `2b3223a02c386d1263e1b08343cb8eb3a53e444cdafb1d79e26c8ec2a8fcad28` |
| SHA-256 of `LICENSE` | `fb1bc6909ac3ef82d5c22106e32ef682b0cff66788fa915fb9b53b15c9d2f3ab` |

## How to update

Updating this skill is its own OpenSpec change that needs owner approval:

1. Fetch upstream at the new commit SHA.
2. Diff the upstream `skills/ponytail/SKILL.md`, `skills/ponytail-review/SKILL.md`, and `skills/ponytail-audit/SKILL.md` against the vendored copies.
3. Check that nothing in the diff conflicts with the precedence rules in `AGENTS.md`.
4. Copy the files unchanged, along with `LICENSE`.
5. Update this file: pinned commit, upstream version, SHA-256 of `SKILL.md` and `LICENSE`, and date vendored.
