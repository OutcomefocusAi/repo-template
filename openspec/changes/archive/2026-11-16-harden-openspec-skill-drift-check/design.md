# Design: harden-openspec-skill-drift-check

## Context

See proposal.md for why. `scripts/check-openspec-skills.sh` (merged in `cb04d40`) builds two sorted path lists, the reference from `openspec init --tools agents --profile core` in a `mktemp -d` directory and the checkout's generated paths, reports missing and extra paths with `comm`, and compares common paths with `cmp -s`. `cmp` follows symlinks and ignores the exec bit, which is D1.

Facts checked on 2026-11-16 at `cb04d40` with OpenSpec 2.0.0:

- All 7 committed generated paths have index mode 100644 (`git ls-files -s`).
- A fresh `init` in an empty git repository writes all 7 as regular `-rw-r--r--` files (umask 0022).
- `list` treats an `openspec-*` folder that is a symlink as one path: the `[ ! -L "$p" ]` guard sends it to the `echo "$p"` branch. GNU `find` without `-L` does the same for a symlink given as a starting point (it prints the link itself, `-type l`, and does not descend). So removing the guard does not change the output on GNU or BSD `find`: QA's mutant 6 is likely an equivalent mutant. The apply re-runs it to confirm (see Decisions 5).

## Goals / Non-Goals

**Goals:**
- A generated path that is a symlink, or whose git mode differs from the reference, fails with a file annotation and a fix (D1).
- Every one of QA's 8 surviving mutants is killed by a self-test, or shown to be equivalent with the reason recorded (D2).
- No other behavior changes; the existing 13 cases still pass unchanged.

**Non-Goals:**
- QA's info items (annotation escaping, npx stderr, CRLF, AGENTS.md wording, closing #34 N2): out of scope per Woody's approval, listed in proposal.md as follow-ups.
- Comparing the worktree exec bit of tracked files (see Decisions 2).
- Windows or `core.symlinks=false` testing.

## Decisions

1. **One mode per path, in git terms.** For each path in both lists, compute a git mode: the reference side from the file system (`-L` gives 120000, `-x` gives 100755, otherwise 100644); the checkout side from the index (`git ls-files -s`) when the path is tracked, otherwise from the file system the same way. Compare before content. Alternative: `stat -c %a` on both sides; rejected because permission bits depend on umask and the platform, while git modes are what CI checks out.
2. **Tracked files use the index mode only.** That is what CI and every clone get. A worktree-only `chmod +x` on a tracked file (not committed) passes locally, and fails as soon as it is committed. Comparing the worktree bit too would fail on `core.fileMode=false` checkouts for no real drift.
3. **Untracked symlinks.** A symlink at a generated path is reported as `symlink:` whether tracked or untracked (from `-L`), because both would become a committed link. An untracked symlink at a path the reference does not generate stays `untracked` as today (it is already a failure). A symlinked `openspec-*` folder stays `missing` plus `extra` as today.
4. **One annotation per path, first match wins:** `symlink`, then `mode`, then `edited` (content), then `untracked` (matching but not committed). The drift count and summary line stay the same.
   - `symlink: is a symbolic link but OpenSpec <pin> generates a regular file (mode 100644). Fix: delete the link, run '<npx> init --tools agents --profile core' and commit the regular file`.
   - `mode: git mode <have> but OpenSpec <pin> generates <want>. Fix: run 'git update-index --chmod=-x -- <path>' (or +x) and 'chmod -x <path>', and commit` (for an untracked file only the `chmod`).
5. **D2 tests target the mutants, not new behavior.** The stub gains `STUB_INIT_MODE` (`fail` exits 3, `empty` writes nothing) and logs the `XDG_CONFIG_HOME` and `XDG_DATA_HOME` it sees. New cases: init fails; init writes nothing (asserts the "generated no skill files" message, so the mutant's flood of `extra` lines does not count); two pins that disagree (asserts "disagrees"); pin `2.0.0-rc.1` with the stub reporting `2.0.0-rc.1` (asserts "not an exact"); matching but untracked `.openspec-target` (asserts "untracked: matches"); `openspec-propose` replaced by a symlink to a copy (asserts `missing` and `extra`); the caller's `XDG_CONFIG_HOME`/`XDG_DATA_HOME` set to scratch dirs and the stub log shows other paths under the dedicated `TMPDIR`, with the caller's dirs left empty; and a dedicated empty `TMPDIR` is empty again after a passing and a failing run. A mutation script (kept in `evidence/`) applies each of the 8 mutants to a scratch copy and runs the self-tests; it is run before the new tests (8 survive, matching QA) and after (each killed, or explained as equivalent). If mutant 6 is equivalent, it is reported as such with the proof, and the guard stays, because it states the intent for any `find` that follows command-line links.
6. **Tests first.** The D1 cases fail on the current script and are committed with the D2 cases before the script change; the recorded run shows the D1 cases failing and every other case passing.

## Risks / Trade-offs

- [A derived repository wants other modes] It changes the check in its own proposal; `init` writes 100644 today.
- [Index read cost] One `git ls-files -s` over `.agents/skills`; negligible.
- [Equivalent mutant] If mutant 6 cannot be killed, the evidence says so with the reason instead of claiming 8 of 8.

## Migration Plan

Apply on the issue branch: approval record, failing self-tests, script change, docs sentence, checks with the mutation run and a live demo, dry archive in a scratch clone, archive as the last commit. Rollback: revert the squash-merge commit.

## Open Questions

None.
