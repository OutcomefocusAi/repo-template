# Design: update-template-openspec-2-1-1

## Context

See proposal.md for why. Facts checked on 2026-11-23 between 8:16 and 8:40 AM AZ against `main` `3166c89ac43179aa1ecc690c2d40decdfbdb9d96` (re-checked in task 1.2; output goes in `evidence/`):

- npm `@fission-ai/openspec`: `latest` 2.1.1 (published 2026-11-19T22:29:03Z), 2.1.0 (2026-11-17T01:15:24Z). `engines.node` is `>=22.20.0` at 2.1.1 (`>=22.12.0` at 2.0.0). License MIT. Dependencies are ranges except `skills` 1.8.1 and `cross-spawn` 7.0.6.
- `npm install --global --no-fund --no-audit --before=2026-11-21T00:00:00Z @fission-ai/openspec@2.1.1` into an empty prefix and cache installs and `openspec --version` prints 2.1.1.
- A scratch copy of `main` with `npx -y @fission-ai/openspec@2.1.1 update`: only the six `.agents/skills/openspec-*/SKILL.md` files change (30 insertions, 29 deletions), `.agents/skills/.openspec-target` and `openspec/config.yaml` are unchanged, and every `generatedBy` line is gone. `openspec validate --all --strict` at 2.1.1 passes 8 of 8.
- With the pins bumped on that copy: `check-openspec-pin.sh` exits 1 with `expected exactly one generatedBy line, found 0` for each skill; `check-openspec-skills.sh` with `OPENSPEC_CMD="npx -y @fission-ai/openspec@2.1.1"` exits 1 with `generated no skill files`.
- In an empty repository, `openspec init --tools agents --profile core` at 2.1.1 writes the six skills to `$HOME/.agents/skills/` plus `$HOME/.agents/.skill-lock.json` and nothing under the repository's `.agents/`; with `--scope project` it writes `.agents/skills/.openspec-target` and the six skills in the repository, byte-identical to what `update` produced, and nothing in `$HOME/.agents`. An unscoped probe on the box wrote the real `~/.agents/`, which was removed after a backup; this is why the check gets a temporary `HOME`.
- 2.1.1 `update` asks "Where should OpenSpec keep this project's skills?" only when interactive and `openspec/config.yaml` lacks `skillsScope: project` (`dist/core/update.js`, `dist/core/project-skills-scope.js`); in CI or from an agent it refreshes the skills where they are.
- Ponytail `96608e0..ebd8654`: `dec89d9` (docs), `affbac1` and `ebd8654` (hook fixes); 13 files under README, `assets/`, `hooks/`, `i18n/` and `tests/`. `git diff 96608e0 ebd8654 -- skills LICENSE` is empty, and the three vendored `SKILL.md` and `LICENSE` files are byte-identical to `ebd8654`. `git describe --tags ebd8654` is `v5.3.3-4-gebd8654`.
- the-ordinary-things `31eb245` (its base for PR #18) has the same `check-openspec-pin.sh`, `check-openspec-skills.sh`, `test-template-scripts.sh`, `ci.yml` and `TEMPLATE_SOURCE.md` as this template's `main`, so `22a924a`'s script and test changes port line for line.

## Goals / Non-Goals

**Goals:**
- The template pins OpenSpec 2.1.1 and Ponytail `ebd8654`, with every record and fingerprint in step.
- Every drift the pin and generated-skills checks caught at 2.0.0 still fails CI at 2.1.1, without a stamp to read.
- CI's OpenSpec install cannot pick up a dependency published after a recorded cutoff, and the bypasses QA found downstream (#21 to #27 there) fail with a file and line.

**Non-Goals:**
- A committed lockfile for OpenSpec (considered in #46 and rejected there for the reasons in its design).
- Global skills, other tools than `agents`, or the extra OpenSpec workflows `update` mentions.
- Changing `AGENTS.md`, `README.md`, Node.js, gitleaks, actionlint or action pins.
- Checking scripts that workflows call (for example `scripts/install-ci-tools.sh`) for npm config writes; they are reviewed code and do not touch npm.

## Decisions

1. **One change for all three parts.** Woody approved a single proposal; the pin bump cannot pass without the check changes, and the cutoff edits the same line and script.
2. **Regenerate with `openspec update` at 2.1.1, with a temporary `HOME`.** Same path as #28, #30 and #35. The temporary `HOME` keeps a real global install out of the box. Stop if the run changes any file besides the six skills.
3. **Record `skillsScope: project` in `openspec/config.yaml`.** It is the key 2.1.x writes when a person picks "Keep in this project". Without it, an interactive `openspec update` in the template or a derived repository offers "Switch to global", which deletes the repository's skills. Alternative: document the choice only (rejected: a prompt default is easy to miss, and the key is cheap and read by the tool itself).
4. **Stamp-free pin check.** `check-openspec-pin.sh` reads each skill's `generatedBy` lines: more than one is an error; exactly one is a version record as before; none is allowed. All skills must share the stamp state of the first skill (all stamped or none). The generated-skills check already fails on any added, removed or edited stamp and on any content not produced by the pinned CLI, and CI runs it on every run. So the set of failing drifts is unchanged: a stale 2.0.0 skill fails both checks (its stamp disagrees, its content differs); a stamp removed by hand fails the generated-skills check; a stamp added by hand fails both. Alternative: demand that no stamp exist (rejected: it ties the script to one upstream behavior and would break if a later version restores stamps). Alternative: query npm for the version's file list (rejected: no network in the self-tests).
5. **Generated-skills reference with `--scope project` and a temporary `HOME`.** The reference command becomes `openspec init --scope project --tools agents --profile core`; `run_openspec` also sets `HOME="$tmp/home"`. Every fix hint names the same command. The "generated no skill files" error stays, so an unscoped or global init still fails loudly. The stub CLI in the self-tests logs its `HOME` and arguments, and the tests assert both.
6. **Cutoff, ported from the-ordinary-things `22a924a` decisions 5 to 9.** One anchored pattern for the whole install line, `^\s*npm install --global --no-fund --no-audit --before=(\S*) @fission-ai/openspec@\S+\s*$`; the cutoff round-trips through `date -u -d` unchanged; it is not earlier than 2020-01-01T00:00:00Z and not later than the check's own UTC clock; any `npm_config_` text in a workflow fails (case-insensitive); the Tool pins row must carry the same `--before=` value as every CI line. Cutoff value `2026-11-21T00:00:00Z`: after 2.1.1's publish and before `@inquirer/expand` 5.2.1 (2026-11-22T00:04:12Z), which broke the-ordinary-things CI; the install was verified in Context.
7. **the-ordinary-things#25 (multi-line bypasses).** For each install line, the check fails if the previous line ends in `\`, or if the nearest preceding `run:` key is not a literal block (`run: |`, `|-` or `|+`) indented less than the install line. A folded `run: >` joins the next line onto the command, which is how QA's n17 passed. Any workflow line matching `npmrc` or `npm (config|c) (set|edit)` or `npm set` (case-insensitive) fails, covering QA's n28 (`~/.npmrc` write). Alternative: parse YAML (rejected: no YAML parser in the pinned toolset; the run-key rule is simple and conservative, and anything it cannot classify fails).
8. **the-ordinary-things#26.** Both pin-check loops read `.github/workflows/*.yml` and `*.yaml`.
9. **the-ordinary-things#27.** The self-tests assert `::error file=TEMPLATE_SOURCE.md,line=<row line>::` for the row-mismatch and row-missing cutoff cases and `::error file=.github/workflows/ci.yml,line=<n>::` for the npm config case, and add a lowercase `npm_config_` case.
10. **Ponytail.** Copy the three `SKILL.md` files and `LICENSE` from `ebd8654` (no byte changes), and update each `SOURCE.md` (pinned commit, link, upstream version text and describe string, date vendored) and the `TEMPLATE_SOURCE.md` row. `check-ponytail-pin.sh` needs no change.

## Test plan (fail first)

- Task 2.1 adds the new pin-check self-tests (cutoff shapes and bounds, row cross-check with line numbers, npm config env in both cases, npmrc and `npm config set`, continuation, folded block, `.yaml` workflow, stamp-free and mixed-stamp skills) and runs them against the unchanged script; the failing count goes in `evidence/`.
- Task 3.1 adds the generated-skills self-tests (`--scope project` in the init arguments, a temporary `HOME` the stub sees, the new fix text) and runs them against the unchanged script; the failing count goes in `evidence/`.
- A mutation pass after implementation flips each new condition in `check-openspec-pin.sh` and `check-openspec-skills.sh` one at a time and records which self-test kills it.

## Risks / Trade-offs

- [The pin check no longer proves the version from the skill files alone] → The generated-skills check does, byte for byte, on every CI run; the pin check still catches mixed and stale stamps.
- [A pin bump must move the cutoff] → `TEMPLATE_SOURCE.md` says so; a cutoff earlier than the pin fails the install with `ETARGET`, never installs an older OpenSpec.
- [The text rules for `npmrc` and npm config could reject a legitimate future workflow line] → It fails loudly with the reason; relaxing it needs its own change.
- [Run-block detection is line based] → It fails closed: an install line it cannot place inside a literal `run: |` block is an error.
- [2.1.x skill text changes] → QA reads the full skill diff; `AGENTS.md` still wins over generated skills (section 3).
- [Derived repositories] → They keep the old checks until they take the next template release; `scripts/template-drift.sh` reports the difference.

## Migration Plan

Apply on the issue branch, one commit per task, failing tests committed before each fix, archive as the last commit before QA, then merge after `SHIP` on that head and green CI. Rollback: revert the squash-merge commit on `main`, which restores 2.0.0, Ponytail `96608e0`, the old skills and the old checks; nothing else to migrate.
