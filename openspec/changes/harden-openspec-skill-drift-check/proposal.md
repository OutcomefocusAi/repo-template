# Proposal: harden-openspec-skill-drift-check

Tracking issue: [#39](https://github.com/OutcomefocusAi/repo-template/issues/39) (parent #37). Branch: `39-harden-openspec-skill-drift-check`, from `main` `cb04d40db7e6af7a0997576ea146954589ff0c37`. Notion Tasks row: pending. Not docs-only and not version-only: it changes `scripts/check-openspec-skills.sh`, adds self-tests and changes `continuous-integration` scenarios. Woody approved the proposal and its apply in one message (see Approval).

## Approval

| What | Words or selected option text | How given, where and when |
| --- | --- | --- |
| The request behind this change | Typed by Woody: "Just trying to fix whatever it is, I don't need anything failing silently." | Typed in Woody's chat with Chief of Staff at 8:47 AM AZ Mon Nov 16, 2026. Chief of Staff relayed it at 9:41 AM AZ as the ask for #39 (Principal QA's follow-up to PR #38). A request to build, not approval |
| Approve this proposal and its apply | Typed by Woody: "Go ahead for this I authorize it" | Typed in Woody's chat with Chief of Staff at 9:41 AM AZ Mon Nov 16, 2026, relayed by Chief of Staff. Covers: this proposal and its apply for the two gaps only, D1 (file mode and symlink drift) and D2 (tests for the surviving mutants). No separate proposal tap is needed. Not covered: anything beyond those two gaps (the QA info items are out of scope below), and merging |

## Why

Principal QA's review of PR #38 (review 5923679878, head `991eb0c`) shipped the drift check but found two Low gaps, filed as #39:

- D1: `scripts/check-openspec-skills.sh` compares content only. A committed `chmod +x SKILL.md` (git mode 100755) or a `SKILL.md` replaced by a symlink to an identical copy (mode 120000) both pass with "7 generated file(s) match", although `openspec init` writes regular 100644 files.
- D2: 8 of 14 targeted mutants of the script survive the self-tests (110/110 still pass): the matching-but-untracked branch, `init` failure, the "generated no skill files" guard, disagreeing pins, the cleanup `trap`, the symlinked-folder guard, the temporary `XDG_CONFIG_HOME`/`XDG_DATA_HOME`, and the exact `MAJOR.MINOR.PATCH` regex. The behavior is correct today, but nothing stops a regression.

Woody wants nothing failing silently.

## What Changes

- `scripts/check-openspec-skills.sh` also compares each generated path's git mode and file type with the reference. A generated path that is a symlink fails with a `symlink:` annotation; a regular file whose mode differs (for example 100755) fails with a `mode:` annotation. Both name the file and the fix. Tracked files use the index mode from `git ls-files -s`; untracked files use the file system (`-L`, `-x`). Everything else in the script stays as it is.
- `scripts/test-template-scripts.sh` gains self-tests, committed before the script change:
  - D1: committed `chmod +x` on a `SKILL.md`, a `SKILL.md` committed as a symlink to an identical copy, and an untracked symlink at a generated path each fail with the expected annotation. These fail first.
  - D2: `init` exits non-zero; `init` writes nothing; two install lines with different versions; a pin that is not exact even when the CLI reports the same string (for example `2.0.0-rc.1`); a matching but untracked `.openspec-target`; an `openspec-*` folder replaced by a symlink to a copy; the stub sees a temporary `XDG_CONFIG_HOME` and `XDG_DATA_HOME`, not the caller's; and no temporary directory is left in a dedicated `TMPDIR` after a passing and a failing run. These pass on the current script (the behavior is right today) and are there to kill the mutants.
- A mutation run over the 8 surviving mutants is part of the evidence, before and after the new tests.
- `TEMPLATE_SOURCE.md`: the sentence on `check-openspec-skills.sh` also names mode and symlink drift.
- `continuous-integration`, requirement "Template checks always run" (text unchanged, 489 characters): two new scenarios (mode or file type changed; reference generation fails), and three existing scenarios gain the cases that were untested (disagreeing pins; a matching file that is not committed; temporary directory removed and caller's config unused).

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `continuous-integration`: "Template checks always run" gains two scenarios and three scenarios are extended. The requirement sentence does not change.

## Impact

- `scripts/check-openspec-skills.sh` (mode and type comparison), `scripts/test-template-scripts.sh` (new cases, stub options), `TEMPLATE_SOURCE.md` (one sentence), `openspec/specs/continuous-integration/spec.md` at archive. No workflow file changes.
- Risks:
  - A derived repository that commits generated skills with another mode on purpose would now fail; `init` writes 100644, so the template's files are 100644 today (checked in apply).
  - On a checkout with `core.symlinks=false`, a committed symlink is a small text file; the index mode still reports 120000, so the check still fails. Not tested on Windows.
  - CI time grows by milliseconds (one `git ls-files -s`).

## Out of scope (follow-ups)

These were QA info items on PR #38. They are not part of Woody's approval and are not implemented here; each can be its own follow-up:

- `::error file=` values are not %-escaped, so a file name with a comma or colon gives a malformed annotation (the exit code is still 1).
- The CLI version probe discards stderr, so a broken `npx` or network error shows version `''` without the cause (it still fails closed).
- CRLF: on Windows with `core.autocrlf=true`, a local run would report every skill as edited; CI is Linux. A `.gitattributes` `eol=lf` for the generated skills would fix it.
- `AGENTS.md` section 7 says generated files are "refreshed by `openspec update`"; the drift check's fix text now also uses `init`.
- Closing #34 N2 with a pointer to the drift check (QA's N4).
