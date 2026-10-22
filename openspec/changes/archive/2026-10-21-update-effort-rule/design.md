# Design

## Context

See proposal.md (Why). Today the rule lives in two places: the `agent-guidance` requirement "AGENTS.md states the maximum effort rule" and `AGENTS.md` section 12 ("Maximum effort"), whose first paragraph requires the highest level for coding, design, debugging, review and verification and for every background worker or subagent, and whose second paragraph is the no-spending rule. No script, test or CI check reads the effort wording, so the change is text only. PR #25 (merged as `a766b44`) edited `AGENTS.md` sections 1 and 8 but not section 12, so the two do not overlap in text.

## Goals / Non-Goals

**Goals:**
- One effort rule, stated the same way in the spec and in `AGENTS.md`, matching Woody's 5:05 PM MST option.
- Generic wording: no agent or bot names, no model or tool names, no em dashes.

**Non-Goals:**
- Any change to approval, QA, merge, traceability, docs-waiver or no-spending rules.
- Naming a specific model or effort setting; "normal" means the tool's default or standard level.
- Editing generated skills under `.agents/skills/`.

## Decisions

- **D1: Rename the requirement.** "maximum effort rule" would be wrong once part of the work may use normal effort, so the requirement becomes "AGENTS.md states the effort rule" through a RENAMED delta plus a MODIFIED block that keeps the existing scenario name "Agent delegates work". Alternative: keep the old name; rejected as misleading for derived repositories.
- **D2: List the normal-effort work, default everything else to highest.** The allowed list is exactly Woody's: docs-only changes (as defined in `AGENTS.md` section 9), OpenSpec archive work, and routine CI or status checks. Anything not on the list, and anything an agent is unsure about, stays at the highest level. Alternative: list the highest-effort work and default to normal; rejected because it would widen his option.
- **D3: Independent QA stays at the highest level.** Woody's option covered docs, archive and routine CI work; it did not mention review. Reading it narrowly, QA review and verification of any change, including a docs-only one, stay at the highest level. Alternative: let QA of docs-only changes run at normal effort; not chosen without his words.
- **D4: Keep section 12's place and the no-spending paragraph.** Section 12 is retitled (for example "Effort level") and its first paragraph rewritten; the no-spending paragraph is unchanged byte for byte. Other sections that cite section 12 by number keep working.
- **D5: Archive in the implementation pull request.** Per Woody's 5:05 PM MST option and `AGENTS.md` section 1 step 7 as merged in PR #25, the archive is the last commit of the implementation pull request, before QA's `SHIP` check, with no separate archive pull request.

## Risks / Trade-offs

- [Agents treat a code change as "docs" to use normal effort] → section 9's definition applies and "when unsure, use the highest level" is in the rule.
- [Another pull request edits section 12 first] → rebase is not allowed, so on apply re-read `AGENTS.md` on the latest `main`, and if section 12 changed, stop and report before editing.
- [D3 is narrower than Woody may want] → listed for his confirmation when he reviews the proposal; changing it later is a one-line spec and text edit.

## Migration Plan

Text only. Derived repositories pick it up through the template drift flow. Rollback is reverting the implementation pull request.
