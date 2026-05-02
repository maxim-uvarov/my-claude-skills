# Git Intent Protocol

Git is the instruction interface between human and agent. The human delivers intent through **commit messages** and inline **`!!` markers** in any file type. The agent reads the diff, executes the instructions, and commits the results. Every change is reviewable in git history.

## Commit patterns

1. `gi:` alone — process markers in committed files; no global instruction
2. `gi: <text>` — process markers AND apply `<text>` globally to the files
3. Commit by user with plain message describing change —  propagate the change in other places of this or relevant docs. Message is context for diff, not an instruction

The subject prefix is `gi:` (quiet — the commit *is* the unit, no surrounding noise to fight) while inline markers are `!!` (loud — they must stand out against surrounding code).

## Markers

- Native comment syntax of the file, prefixed with `!!`, always single-line
- Place on the line above or beside the target code
- Removed after processing (remove the whole comment, including any closing delimiters like `*/` or `-->`, not just the `!!` token)
- HTML/plain comments without `!!` are persistent context — leave alone

See `examples/marker-syntax.md` for per-language syntax.

!! but do we really need the `conflict resolution`? I expect to be mindful about my edits. Though, I guess, it would be good to signal me if start contradict myself.
## Conflict resolution (in order)

1. **File marker > commit message** — a marker is tied to a location, more specific than a general commit message
2. **Later marker > earlier marker** — top-to-bottom; if a later marker invalidates an earlier one's result, the later wins. Though in the final commit message the conflict of instructions must be acknowledged
3. **User's committed edit > prior markers** — if the user edited code a marker targets, the edit *is* the decision; remove the marker without re-applying it
4. **Clean up broken surroundings after rule 3** — if the user's edit left a dangling sentence, stale list numbering, or broken syntax, fix it. Never re-add content the user removed
5. **Genuine ambiguity** — stop and ask rather than guess

## Agent commits

Each logical change is its own commit. Subject = what changed. Body is mandatory and follows this template:

```
<subject>

Decision: <one sentence>
Why: <non-obvious reasoning, 1–2 sentences>
Propagated: <other places touched — omit this line if none>
```

- **Don't list conflicts you looked for and didn't find.** "Nothing else changed" is noise; absence is the default.
- **Don't restate the diff.** If the body is longer than the diff, the body is wrong unless the reasoning is genuinely complex.
- **Skip binary files** in the diff.
- A decision visible in git history is binding — do not override without explicit instruction.
