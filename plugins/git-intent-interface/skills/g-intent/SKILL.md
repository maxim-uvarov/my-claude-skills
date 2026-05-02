---
name: g-intent
version: 0.2.0
description: Process commits as instructions — execute `!!` markers and propagate user-committed choices through the codebase. Use when the user says "g-intent", "apply intent", or "process last N commits".
argument-hint: <N>
allowed-tools: Bash, Read, Edit, Write, Grep, Glob
---

Protocol rules (commit patterns, marker syntax, reading user edits, commit body template) are in `references/protocol.md`. Read it before editing anything.

If `$ARGUMENTS` is empty or not a positive integer, default to `1`.

## Procedure

1. **Clean-tree check** — run `git status --porcelain`. If non-empty, stop and ask the user to commit or stash.

2. **Get the diff** — run `git log -p -N --reverse` where `N = $ARGUMENTS`. If the patch is very large (>500 lines), prefer `git log -N --stat` plus targeted `git show` per file to avoid filling context.

3. **Read files in scope** in full. Skip files you've already read or edited in this session, and skip binary files.

4. **For each commit, run the pipeline:**
   - **Apply markers** — for each `!!` marker added in the diff, read the instruction text, apply it to the target code/text, remove the whole marker comment (including any closing delimiters like `*/` or `-->`).
   - **Apply global instruction** — if the subject is `gi: <text>`, apply `<text>` to all files in the commit.
   - **Propagate the decision** — scan each file in the commit scope for references that contradict the resulting state (stale branches, removed APIs, old behavior descriptions, obsolete rationale). If the decision names a symbol, path, API, or config key, also `grep` the broader repo. Clean up broken surroundings (dangling sentences, stale list numbering, broken syntax) left by user edits. Resolve edit-vs-marker interactions per the protocol's *Reading user edits* section.

   Empty markers, empty global instruction, and no propagation needed are all valid no-ops — the pipeline runs unconditionally.

5. **Commit each logical change** — one commit per decision, using the body template in the protocol. Per the protocol's *Surface contradictions* rule: when scope is unclear, name your interpretation in the commit body if you can resolve it; ask the user if you can't. If there is genuinely nothing to do (no markers, no propagation, no cleanup), report it and exit without creating an empty commit.

## Related

- `/g-intent-squash-archive` — when done iterating, squash the branch into one clean commit preserved as a git tag
