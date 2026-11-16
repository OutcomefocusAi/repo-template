# Design: test-openspec-skill-parent-dir-halves

## Context

See proposal.md for why. Since #41 (`47155c5`), `scripts/check-openspec-skills.sh` checks `.agents` and `.agents/skills` with `if [ -L "$d" ] || [ "$(idx_mode "$d")" = 120000 ]`, where `idx_mode` reads `git ls-files -s -- .agents`. The two E1 self-tests commit the link (`git add -A`), so both halves are true at once. The self-test helper resets the index and working tree of `.agents` after each case and removes `.agents` or `.agents/skills` links first.

## Goals / Non-Goals

**Goals:**
- One self-test where only the on-disk half is true and one where only the index half is true, each asserting the `symlink:` annotation on the right directory.
- The on-disk-half mutant (QA E1-4) and the index-half mutant (QA E1-5) are each killed by their own test; QA's related survivors E1-6 (index read narrowed) and E1-11 (160000) are killed too.

**Non-Goals:**
- Any change to `scripts/check-openspec-skills.sh`.
- QA's PR #43 info items N1 (cleanup order) and N4 (message wording): follow-ups in proposal.md. Neither is needed for F1: the new fixtures never leave `.agents` as a link on disk, so the cleanup order does not matter for them.

## Decisions

1. **On-disk only, on `.agents/skills`.** Fixture: move `.agents/skills` to `.agents/skills-real`, link `.agents/skills` to it, and do not stage anything. The index still lists the real `.agents/skills/*` files, so `idx_mode .agents/skills` is empty and only `[ -L ]` is true. The linked copy is identical, so without the on-disk half the run would pass with "7 generated file(s) match" (the silent pass QA showed). Asserts `::error file=.agents/skills,line=1::symlink:`. The existing cleanup removes the link and `.agents/skills-real`.
2. **Index only, on `.agents`.** Fixture: `git rm -r --cached .agents`, then `git update-index --add --cacheinfo 120000,<blob>,.agents`, where the blob is the link target text written with `git hash-object -w --stdin`. The real `.agents` directory stays on disk, untouched, as it would after a `core.symlinks=false` checkout of a committed link. Only the index half is true; the generated files also report `untracked:`. Asserts `::error file=.agents,line=1::symlink:`. Using `.agents` (not `.agents/skills`) also kills QA's E1-6 mutant (index read narrowed back to `.agents/skills`). The cleanup's `git reset -- .agents` restores the index; the extra blob stays in the scratch repository's object store, which is deleted with it.
3. **Alternative considered for the index-only case:** a fresh clone with `core.symlinks=false`. Rejected for the self-test because the helper runs in one scratch repository; the `--cacheinfo` index edit gives the same index and disk state without a second clone. The live demo can still show the `core.symlinks=false` case.
4. **Mutation demo.** `evidence/mutants.sh` (copied from #41's archived evidence) gains `--f` with four mutants of the E1 condition: 16 on-disk half dropped (QA E1-4), 17 index half dropped (QA E1-5), 18 index read narrowed to `.agents/skills` (QA E1-6), 19 compare 160000 (QA E1-11). Run before the new tests (all four survive) and after (all four killed, each by the expected test).
5. **Spec.** OpenSpec needs a delta for a change, and the behavior is worth stating: one new scenario under "Template checks always run" says either half alone fails. The requirement sentence is unchanged.

## Risks / Trade-offs

- [Test-only change] No user-facing behavior changes; the risk is only a wrong fixture, covered by the before and after mutation runs.

## Migration Plan

Apply on the issue branch: mutation demo on the current tests, the two self-tests, the mutation demo again, checks, dry archive in a scratch clone, archive as the last commit. Rollback: revert the squash-merge commit.

## Open Questions

None.
