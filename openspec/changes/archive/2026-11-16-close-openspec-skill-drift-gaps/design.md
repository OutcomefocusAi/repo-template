# Design: close-openspec-skill-drift-gaps

## Context

See proposal.md for why. After #39 (`d7046b4`), `scripts/check-openspec-skills.sh` lists the generated paths under `.agents/skills/` with a glob and `find`, reads the index with `git ls-files -s -- .agents/skills`, and for each generated path compares a git mode (`mode_of`: on-disk symlink first, then the index mode for tracked files, else the file system) and then content. Nothing looks at the parent directories: a glob through a symlinked `.agents/skills` finds the files behind the link, and `[ -L ]` is false on the files themselves, so an identical linked copy passes (E1, QA cases 36 and 36b). `git ls-files -s -- .agents/skills` already lists a 120000 entry for `.agents/skills` itself, but not one for `.agents`.

## Goals / Non-Goals

**Goals:**
- A symlinked `.agents` or `.agents/skills`, on disk or committed, fails with a `symlink:` annotation naming the directory and a fix (E1).
- QA's surviving non-equivalent mutant D1d is killed, and D1f and D1j are killed by asserting the untracked `mode:` message and fix (E2).
- Everything else behaves as before; the existing 124 cases still pass unchanged.

**Non-Goals:**
- QA's PR #40 info items (exec-bit comment, SC2012, gitlinks, the mutant 6 guard comment, N5, N6): follow-ups in proposal.md.
- Other ancestors (the repository root itself) and any directory outside `.agents/skills`.

## Decisions

1. **Check the two ancestors explicitly.** Before comparing files, for `.agents` and `.agents/skills`: fail if `[ -L "$d" ]` or the index has a 120000 entry for exactly that path. The index read widens from `-- .agents/skills` to `-- .agents` so one lookup function (`idx_mode`, the existing awk exact match moved out of `mode_of`) serves both. `mode_of` keeps its logic. Alternative: resolve `realpath .agents/skills` and compare with the expected path; rejected because it misses a committed link checked out with `core.symlinks=false` (a text file), which the index entry catches.
2. **One annotation per linked directory, files still compared.** The directory gets `symlink: this directory is a symbolic link (git mode 120000) but OpenSpec <pin> generates a real directory. Fix: delete the link, run '<npx> init --tools agents --profile core' and commit the real directory`. The file comparison still runs, so a link to a non-identical copy also reports its file drift; a link to an identical copy reports only the directory. The drift count includes it.
3. **E2 tests pin existing behavior.** New cases: a tracked `openspec-archive-change/SKILL.md` replaced on disk by an uncommitted symlink to an identical copy (asserts `symlink:` for that file; kills D1d), and an untracked executable generated file (`git rm --cached`, `chmod +x`; asserts `mode: git mode 100755` and `chmod -x <path>' and commit it with 'git add -- <path>`; kills D1f and D1j).
4. **Test cleanup for linked directories.** The self-test helper resets `.agents` after each case with `git reset`, `git checkout` and `git clean`. With `.agents/skills` or `.agents` replaced by a link, `git checkout` would refuse paths beyond a symlink, so the helper removes those two links first and also cleans the fixture's copy directory. This touches only the test harness.
5. **Mutation run.** `evidence/mutants.sh` (copied from #39's archived evidence) gains `--e` with QA's D1d, D1f, D1j and a mutant that disables the new ancestor check. It runs before the new tests (D1d, D1f, D1j survive, as QA reported) and after (all killed). Mutant 6 stays equivalent.
6. **Tests first.** The E1 cases fail on the current script and are committed with the E2 cases before the script change.
7. **The mutant 6 guard comment is not added.** The E1 change is a separate block before the comparison and does not touch `list()`, so a comment there would not be a natural part of it.

## Risks / Trade-offs

- [Shared-skills setups] A repository that links `.agents` on purpose fails; it changes the check in its own proposal.
- [Widened index read] `git ls-files -s -- .agents` also lists Ponytail files; lookups are exact-path, so nothing else changes.

## Migration Plan

Apply on the issue branch: failing self-tests, script change, checks with the mutation run and a live demo, dry archive in a scratch clone, archive as the last commit. Rollback: revert the squash-merge commit.

## Open Questions

None.
