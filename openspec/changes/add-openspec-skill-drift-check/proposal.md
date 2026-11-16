# Proposal: add-openspec-skill-drift-check

Tracking issue: [#37](https://github.com/OutcomefocusAi/repo-template/issues/37). Branch: `37-add-openspec-skill-drift-check`, from `main` `94df7b221389b98fda62901731a988c0834f76a5`. Notion Tasks row: https://app.notion.com/p/41a444b092e68198baa9f1d5d0f26f81. Not docs-only and not version-only: it adds a script, a CI step, self-tests and a requirement change, so it needed Woody's approval of this proposal before apply (given 2026-11-16 9:12 AM AZ, see Approval).

## Approval

| What | Words or selected option text | How given, where and when |
| --- | --- | --- |
| Fix QA's PR #36 info item N1 (the request behind this change) | Typed by Woody: "Just trying to fix whatever it is, I don't need anything failing silently or whatever" | Typed in Woody's chat with Chief of Staff at 8:47 AM AZ Mon Nov 16, 2026, relayed by Chief of Staff as his yes to Principal QA's PR #36 info item (a CI step that fails when `openspec update` would change the skill files, with a clear error naming what drifted and how to fix it). A request to build, not approval of this proposal |
| Approve this proposal | Selected option: "Yes, approve the drift check proposal" on the card "approve the skill drift check for repo-template (issue #37)" | Tapped by Woody in his chat with Chief of Staff at 9:12 AM AZ Mon Nov 16, 2026, relayed by Chief of Staff. Covers: applying add-openspec-skill-drift-check (proposal head ef308ee) only. Not covered: merging (this adds CI behavior, so the merge comes back to Woody) |

## Why

The `agent-guidance` scenario "Skills present" says the six OpenSpec skills are "unmodified from generation", and the 2.0.0 scenario "Skills are invoked by name" depends on the same thing, but only a reviewer checks it. `check-openspec-pin.sh` compares version stamps, so a hand edit to a skill's text, a deleted skill folder (#34 N2) or an extra file under `.agents/skills/openspec-*/` passes CI today. Principal QA flagged this in the PR #36 review, and Woody wants nothing failing silently.

## What Changes

- New script `scripts/check-openspec-skills.sh` (Bash glue, same style as `check-openspec-pin.sh`):
  - reads the OpenSpec version from the `@fission-ai/openspec@<version>` install line in `.github/workflows/ci.yml` (never `latest`), and fails if that line is missing, repeated with different versions, or not an exact `MAJOR.MINOR.PATCH`;
  - fails if the `openspec` CLI it runs does not report that exact version;
  - generates a fresh reference with `openspec init --tools agents --profile core` in a temporary directory outside the checkout, with a temporary OpenSpec config directory, so neither the checkout nor the user's global OpenSpec config is touched;
  - compares the OpenSpec-generated skill files (`.agents/skills/.openspec-target` and everything under `.agents/skills/openspec-*/`) in the checkout, tracked and untracked, with the reference;
  - prints one `::error file=<path>,line=1::` annotation per drifted file, saying whether it is edited, missing, extra or untracked, and the fix: run `npx -y @fission-ai/openspec@<pin> init --tools agents --profile core` (or `update`) and commit the result, or revert the hand edit with `git checkout -- <path>`; for an extra or untracked file, delete it or move a custom skill to a name that does not start with `openspec-`;
  - on success prints `check-openspec-skills: <n> generated file(s) match OpenSpec <pin>`.
- `scripts/test-template-scripts.sh` gains self-test cases, written and committed failing first, using a stub `openspec` command so the self-tests need no network: clean tree passes; edited skill, edited stamp, deleted `SKILL.md`, deleted skill folder, extra tracked file, untracked new `openspec-*` folder, CLI at a different version than the pin, CI pin missing or a range, and missing CLI each fail; the checkout's `git status` is the same before and after every case, and the stub's generation never runs inside the checkout.
- `.github/workflows/ci.yml` `template-checks` gains a step "OpenSpec skills match generation" right after "OpenSpec pin agreement". It uses the OpenSpec CLI the job already installs from the pinned npm version, so it adds no new download.
- One sentence in `TEMPLATE_SOURCE.md` under the Tool pins table names the new check and the fix command.
- The `continuous-integration` requirement "Template checks always run" lists the new check and gains scenarios for clean skills, edited skills, missing files, extra or untracked files, the version source, and an unchanged checkout.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `continuous-integration`: "Template checks always run" adds the generated-skills check and six scenarios.

## Impact

- New `scripts/check-openspec-skills.sh`; `scripts/test-template-scripts.sh` (new cases and a stub `openspec`); `.github/workflows/ci.yml` (one new `run:` step, no action, permission, trigger or pin change); `TEMPLATE_SOURCE.md` (one sentence); `openspec/specs/continuous-integration/spec.md` at archive.
- Running the check locally needs the pinned OpenSpec CLI on `PATH` (or `npx`); without it the check fails with the install command instead of skipping.
- Related #34 items: N2 (a deleted skill folder passes the pin check) is caught by the new check; N1, N3, N4 and N5 stay open in #34 and are out of scope.
- Out of scope: `openspec/config.yaml` (project-owned; derived repositories add `context` and `rules`), the `.gitkeep` files, vendored Ponytail skills (already fingerprinted), other OpenSpec profiles or tools, and running the check in derived repositories differently from the template.
- Risks:
  - A future OpenSpec release that changes what `init --tools agents --profile core` writes (for example a new marker file) makes the check fail until the version bump regenerates the skills, which is the point; the error names the files.
  - A derived repository that picks a different OpenSpec profile or adds tools will fail the check until the script's profile and tools are adjusted in its own proposal.
  - `openspec init` might one day need the network or prompt; the stub-based self-tests would not see that. The CI step on the real CLI would, and fails rather than passes.
  - CI time grows by a few seconds (one `init` in a temp directory).
