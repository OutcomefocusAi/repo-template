Closes #<issue>

- OpenSpec change folder: `openspec/changes/<change-name>/`
- Notion Tasks row: <link or none>
- Workflow files changed: <yes, list them / no>

## Requirement-to-test map

| Requirement / scenario | Test or evidence |
| --- | --- |
| <requirement>: <scenario> | <test name, command output, or CI link> |

## Evidence

- [ ] Lint: <CI link or output>
- [ ] Typecheck: <CI link or output>
- [ ] Test: <CI link or output>
- [ ] Coverage (80% new code, 90% money and critical paths): <CI link or output>
- [ ] Build: <CI link or output>
- [ ] `openspec validate --all --strict`: <output>
- [ ] Not run, and why: <list or none>

## QA verdict

Principal QA posts the verdict as a comment. Its first line must be:

`Independent QA by <reviewer>: <SHIP | SHIP WITH FIXES | NO-SHIP>`

followed by the full head SHA tested and the evidence. `qa-gate` passes only on SHIP for the current head.
