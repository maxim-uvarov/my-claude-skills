# Git Intent Protocol

Git is the instruction interface between human and agent. The human
delivers intent through **commit messages** and inline **`!!` markers** in
any file type. The agent reads the diff, executes the instructions, and
commits the results. Every change is reviewable in git history; when in
doubt, the agent should make the change and commit rather than ask.

## Commit patterns

1. `!!` alone — process markers in committed files; no global instruction
2. `!! <text>` — process markers AND apply `<text>` globally to the files
3. Commit by user with plain message describing change —  propagate the change in other places of this or relevant docs. Message is context for diff, not an instruction

## Markers

- Native comment syntax of the file, prefixed with `!!`, always single-line
- Place on the line above or beside the target code
- Removed after processing (remove the whole comment, including any
  closing delimiters like `*/` or `-->`, not just the `!!` token)
- `[keep]` anywhere in the marker preserves it as-is; the `[keep]`
  keyword stays; the user removes it manually
- HTML/plain comments without `!!` are persistent context — leave alone

See `examples/marker-syntax.md` for per-language syntax.

## Conflict resolution (in order)

1. **File marker > commit message** — a marker is tied to a location,
   more specific than a general commit message
2. **Later marker > earlier marker** — top-to-bottom; if a later marker
   invalidates an earlier one's result, the later wins
3. **User's committed edit > prior markers** — if the user edited code
   a marker targets, the edit *is* the decision; remove the marker
   without re-applying it
4. **Clean up broken surroundings after rule 3** — if the user's edit
   left a dangling sentence, stale list numbering, or broken syntax,
   fix it. Never re-add content the user removed
5. **Genuine ambiguity** — stop and ask rather than guess

## Agent commits

Each logical change is its own commit. Subject = what changed. Body is
mandatory and follows this template:

```
<subject>

Trigger: <commit subject or marker text + location>
Decision: <one sentence>
Why: <non-obvious reasoning, 1–2 sentences>
Propagated: <other places touched — omit this line if none>
```

- **Don't list conflicts you looked for and didn't find.** "Nothing else
  changed" is noise; absence is the default.
- **Don't restate the diff.** If the body is longer than the diff, the
  body is wrong unless the reasoning is genuinely complex.
- **Skip binary files** in the diff.
- A decision visible in git history is binding — do not override
  without explicit instruction.

## Workflow

1. Edit any file; add `!!` markers as inline instructions where needed
2. `git commit` with `!!`, `!! <instruction>`, or a plain explanatory
   message
3. Invoke `/g-intent N` to process the last N commits
4. Agent reads the diff, classifies each commit, processes markers,
   propagates choices, and commits each logical change separately
