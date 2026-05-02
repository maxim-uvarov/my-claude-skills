# Git Intent Protocol

Git is the instruction interface between human and agent. The human delivers intent through **commit messages** and inline **`!!` markers** in any file type. The agent reads the diff, executes the instructions, and commits the results. Every change is reviewable in git history.

## Commit patterns

A commit subject may carry an optional global instruction prefixed with `gi: <text>` — this applies to all files in the commit. Otherwise the subject is context for the diff, not an instruction. The agent treats every commit the same: apply any `!!` markers, apply any `gi: <text>` global instruction, propagate the resulting decision to stale references elsewhere. Empty steps are no-ops.

The subject prefix is `gi:` (quiet — the commit *is* the unit, no surrounding noise to fight) while inline markers are `!!` (loud — they must stand out against surrounding code).

## Markers

- Native comment syntax of the file, prefixed with `!!`, always single-line
- Place on the line above or beside the target code
- Removed after processing (remove the whole comment, including any closing delimiters like `*/` or `-->`, not just the `!!` token)
- HTML/plain comments without `!!` are persistent context — leave alone

See `examples/marker-syntax.md` for per-language syntax.

## Reading user edits

- **User's committed edit > prior markers** — if the user edited code a marker targets, the edit *is* the decision; remove the marker without re-applying it
- **Clean up broken surroundings** — if the user's edit left a dangling sentence, stale list numbering, or broken syntax, fix it. Never re-add content the user removed
- **Surface contradictions** — when markers/edits conflict or scope is unclear, name the conflict in the commit body if you can resolve it, ask the user if you can't

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
