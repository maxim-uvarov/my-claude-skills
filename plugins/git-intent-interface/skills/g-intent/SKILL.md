---
name: g-intent
version: 0.2.0
description: Process commits as instructions — execute `!!` markers and propagate user-committed choices through the codebase. Use when the user says "g-intent", "apply intent", or "process last N commits".
argument-hint: <N>
allowed-tools: Bash, Read, Edit, Write, Grep, Glob
---

Git is the instruction interface between human and agent. The human delivers intent through commit messages and inline `!!` markers in any file type. The agent reads the diff, executes the instructions, and commits the results. Every change is reviewable in git history.

If `$ARGUMENTS` is empty or not a positive integer, default to `1`.

## Commit patterns

A commit subject may carry an optional global instruction prefixed with `gi: <text>` — this applies to all files in the commit. Otherwise the subject is context for the diff, not an instruction. The agent treats every commit the same: apply any `!!` markers, apply any `gi: <text>` global instruction, propagate the resulting decision to stale references elsewhere. Empty steps are no-ops.

The subject prefix is `gi:` (quiet — the commit *is* the unit, no surrounding noise to fight) while inline markers are `!!` (loud — they must stand out against surrounding code).

## Markers

- Native single-line comment of the file, prefixed with `!!`. Examples: `# !! ...` (Python/Nu/Shell/YAML), `// !! ...` (JS/Rust/Go/C), `-- !! ...` (SQL), `/* !! ... */` (CSS), `<!-- !! ... -->` (HTML/Markdown).
- Place on the line above or beside the target code
- Removed after processing — remove the whole comment including any closing delimiters (`*/`, `-->`), not just the `!!` token
- Comments without `!!` are persistent context — leave alone

## Reading user edits

- **User's committed edit > prior markers** — if the user edited code a marker targets, the edit *is* the decision; remove the marker without re-applying it
- **Clean up broken surroundings** — if the user's edit left a dangling sentence, stale list numbering, or broken syntax, fix it. Never re-add content the user removed
- **Surface contradictions** — when markers/edits conflict or scope is unclear, name the conflict in the commit body if you can resolve it, ask the user if you can't

## Procedure

1. **Clean-tree check** — run `git status --porcelain`. If non-empty, stop and ask the user to commit or stash.

2. **Get the diff** — run `git log -p -N --reverse` where `N = $ARGUMENTS`. If the patch is very large (>500 lines), prefer `git log -N --stat` plus targeted `git show` per file to avoid filling context.

3. **Read files in scope** in full. Skip files you've already read or edited in this session, and skip binary files.

4. **For each commit, run the pipeline:**
   - **Apply markers** — for each `!!` marker added in the diff, read the instruction text, apply it to the target code/text, remove the whole marker comment (including any closing delimiters like `*/` or `-->`).
   - **Apply global instruction** — if the subject is `gi: <text>`, apply `<text>` to all files in the commit.
   - **Propagate the decision** — scan each file in the commit scope for references that contradict the resulting state (stale branches, removed APIs, old behavior descriptions, obsolete rationale). If the decision names a symbol, path, API, or config key, also `grep` the broader repo. Clean up broken surroundings left by user edits, per *Reading user edits* above.

   Empty markers, empty global instruction, and no propagation needed are all valid no-ops — the pipeline runs unconditionally.

5. **Commit each logical change** — one commit per decision. When scope is unclear, name your interpretation in the commit body if you can resolve it; ask the user if you can't (per *Reading user edits*). Body is mandatory and follows this template:

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

   If there is genuinely nothing to do (no markers, no propagation, no cleanup), report it and exit without creating an empty commit.

## Related

- `/g-intent-squash-archive` — when done iterating, squash the branch into one clean commit preserved as a git tag
