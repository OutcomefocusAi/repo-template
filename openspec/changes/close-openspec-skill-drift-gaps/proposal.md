# Proposal: close-openspec-skill-drift-gaps

Tracking issue: [#41](https://github.com/OutcomefocusAi/repo-template/issues/41) (parent #39). Branch: `41-close-openspec-skill-drift-gaps`, from `main` `d7046b4d0aeb5b0cbde6f7833d2242668ba6b3b0`. Notion Tasks row: https://app.notion.com/p/41a444b092e681e4b83ad6c058db3b86. Not docs-only and not version-only: it changes `scripts/check-openspec-skills.sh`, adds self-tests and extends one `continuous-integration` scenario. Woody approved the proposal and its apply in one tap (see Approval).

## Approval

| What | Words or selected option text | How given, where and when |
| --- | --- | --- |
| Approve this proposal and its apply | Selected option: "Yes, merge PR #40 and go ahead and fix #41 next" | Tapped by Woody in Chief of Staff's chat at 10:24 AM AZ Mon Nov 16, 2026, relayed by Chief of Staff. Covers: the #41 proposal and its apply, with no separate proposal tap, for the two gaps only: E1 (a symlinked `.agents` or `.agents/skills` passes) and E2 (tests for the surviving index-versus-disk mutant and an untracked executable file). Not covered: merging (Woody taps via Chief of Staff), and anything beyond E1 and E2 |

## Why

Principal QA's review of PR #40 (review 5924096229, head `9ec9668`) shipped the mode and symlink check but found two Low gaps, filed as #41:

- E1: committing `.agents/skills` (or `.agents`) as a symlink to an identical copy passes with "7 generated file(s) match", also in a fresh clone (what CI sees). The check only looks at each generated path's own mode. `init` writes real directories, and a `core.symlinks=false` checkout would turn the link into a text file and lose every skill.
- E2: the mutant that lets the index mode win over an on-disk symlink (`if [ -L "$1" ] || [ -z "$m" ]` to `if [ -z "$m" ]` in `mode_of`) survives 124/124 and is not equivalent: a tracked `SKILL.md` swapped for an uncommitted identical symlink fails on the original and passes on the mutant. Two weaker survivors only change the message: `fsmode` ignoring `-x` (an untracked executable file says `untracked:` instead of `mode:`), and the untracked `mode:` fix text, which no test asserts.

Woody wants nothing failing silently.

## What Changes

- `scripts/check-openspec-skills.sh`: `.agents` and `.agents/skills` must be real directories. If either is a symlink on disk or has a 120000 entry in the index, the check fails with one `symlink:` annotation for that directory and the fix. The index lookup used for generated files is shared (no behavior change for them).
- `scripts/test-template-scripts.sh`, committed before the script change:
  - E1: `.agents/skills` committed as a symlink to an identical copy, and `.agents` committed as one, each fail with `symlink:` naming the directory. These fail first.
  - E2: a tracked `SKILL.md` replaced on disk by an uncommitted symlink to an identical copy fails with `symlink:`; an untracked executable generated file fails with `mode: git mode 100755` and the `chmod -x ... git add` fix. These pass on the current script and are there to kill the mutants.
- A mutation run (QA's D1d, D1f and D1j plus a mutant of the new E1 code, alongside the earlier 11) before and after the new tests, and a live 2.0.0 demo of E1.
- `continuous-integration`, requirement "Template checks always run" (text unchanged, 489 characters): the scenario "Generated skill mode or file type changed" also covers a symlinked `.agents` or `.agents/skills` and an uncommitted link over a tracked file.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `continuous-integration`: one scenario of "Template checks always run" is extended. The requirement sentence does not change.

## Impact

- `scripts/check-openspec-skills.sh`, `scripts/test-template-scripts.sh`, `openspec/specs/continuous-integration/spec.md` at archive. No workflow or other doc changes.
- Risk: a derived repository that keeps `.agents` as a symlink on purpose (for example to share skills) now fails; it changes the check in its own proposal.

## Out of scope (follow-ups)

QA info items from the PR #40 review, not part of Woody's approval and not implemented here:

- A code comment that an exec bit set on disk but not staged passes by design (tracked modes come from the index; QA N3).
- shellcheck SC2012 (info) at `scripts/test-template-scripts.sh:241`, the `ls -A` in the TMPDIR assertion (QA N4).
- A gitlink (160000) at an `openspec-*` path with an identical file on disk passes locally; a fresh clone fails with `missing`, so CI fails safe (QA N2).
- A one-line comment on the mutant 6 guard in `list()` explaining why it stays (QA N1). The E1 edit does not touch that line, so it is left as a follow-up.
- QA N5 (prefix-match mutant in the awk lookup, near-equivalent) and N6 (`awk -v` backslash escapes; generated names have none).
