# Proposal: test-openspec-skill-parent-dir-halves

Tracking issue: [#44](https://github.com/OutcomefocusAi/repo-template/issues/44) (parent #41). Branch: `44-test-openspec-skill-parent-dir-halves`, from `main` `47155c57c3790e30e038c629ff8788960387fcc0`. Notion Tasks row: https://app.notion.com/p/41a444b092e681548a67ef9b4f8245a7. Test-only: it adds self-tests and one spec scenario; `scripts/check-openspec-skills.sh` does not change. Woody approved the proposal and its apply in one tap (see Approval).

## Approval

| What | Words or selected option text | How given, where and when |
| --- | --- | --- |
| Approve this proposal and its apply | Selected option: "Yes, merge PR #43 and fix #44 now" | Tapped by Woody in Chief of Staff's chat at 11:03 AM AZ Mon Nov 16, 2026, relayed by Chief of Staff. Covers: the #44 proposal and its apply, with no separate proposal tap, for the test-only gap F1: one on-disk-only and one index-only self-test for the E1 parent-directory check, each killing its own half's mutant. Not covered: merging (Woody taps via Chief of Staff), and anything beyond F1 |

## Why

Principal QA's review of PR #43 (review 5924719542, head `5db1877`) shipped the E1 check `if [ -L "$d" ] || [ "$(idx_mode "$d")" = 120000 ]` for `.agents` and `.agents/skills`, but found one Low gap, filed as #44 (F1): both E1 self-tests commit the link, so the link is on disk and in the index at once and either half alone passes them.

- Dropping the on-disk half (`[ -L "$d" ] ||`) survives 128/128 and is not equivalent: an uncommitted `.agents/skills` link then passes silently in a local run.
- Dropping the index half (`if [ -L "$d" ]`), comparing against 160000, or narrowing the index read back to `.agents/skills` also survive; the run still fails but loses the `symlink:` annotation (index 120000 with a real directory on disk, or a `core.symlinks=false` checkout).

Woody wants nothing failing silently.

## What Changes

- `scripts/test-template-scripts.sh` gains two self-tests:
  - On-disk only: `.agents/skills` replaced by an uncommitted symlink to an identical copy (the index still holds the real tree). Expects `::error file=.agents/skills,line=1::symlink:`.
  - Index only: `.agents` recorded in the index as a symlink (mode 120000) while a real, identical `.agents` directory stays on disk, as a `core.symlinks=false` checkout or a staged link would leave it. Expects `::error file=.agents,line=1::symlink:`.
- A mutation demo: the on-disk-half and index-half mutants (and QA's two related survivors) survive the current 128 tests, and each is killed after the new tests.
- `continuous-integration`, requirement "Template checks always run" (text unchanged, 489 characters): one new scenario stating that either half alone fails.
- No script, workflow or doc change.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `continuous-integration`: "Template checks always run" gains one scenario. The requirement sentence does not change.

## Impact

- `scripts/test-template-scripts.sh` (two cases, about 6 lines) and `openspec/specs/continuous-integration/spec.md` at archive.
- Risk: none for users; CI time grows by well under a second.

## Out of scope (follow-ups)

QA info items from the PR #43 review, not part of Woody's approval and not implemented here:

- N1: the test cleanup removes `.agents/skills` before `.agents`; with a future fixture that links `.agents` outside the scratch directory, the first `rm` could follow that link. Removing `.agents` first avoids it. The two new fixtures do not link `.agents` on disk, so F1 does not need it.
- N4: the directory `symlink:` annotation names one mode ("git mode 120000 ... generates a real directory") while the scenario wording says "with both modes".
- N2 and N3 (near-equivalent prefix-match mutant, message-only survivors), and the carried items: SC2012 and SC2016 infos, the gitlink local pass, the unstaged exec bit comment, the mutant 6 guard comment.
