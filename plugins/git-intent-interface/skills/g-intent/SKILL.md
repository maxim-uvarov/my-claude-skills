---
name: g-intent
version: 0.2.0
description: >-
  Process commits as instructions — execute `!!` markers and propagate
  user-committed choices through the codebase. Use when the user says
  "g-intent", "apply intent", or "process last N commits".
argument-hint: <N>
allowed-tools: Bash, Read, Edit, Write, Grep, Glob
---

Protocol rules (commit patterns, marker syntax, conflict resolution,
commit body template) are in `references/protocol.md`. Read it before
editing anything.

If `$ARGUMENTS` is empty or not a positive integer, default to `1`.

## Procedure

1. **Clean-tree check** — run `git status --porcelain`. If non-empty,
   stop and ask the user to commit or stash.

2. **Get the diff** — run `git log -p -N --reverse` where `N =
   $ARGUMENTS`. If the patch is very large (>500 lines), prefer
   `git log -N --stat` plus targeted `git show` per file to avoid
   filling context.

3. **Classify each commit** in the range:

   - **Marker commit** — the diff adds `!!` markers, or the subject is
     `!!` / `!! <text>`. Run the apply procedure (step 5).
   - **Choice commit** — plain subject, no new markers; the user's
     edits *are* the decision. Run the propagation procedure (step 6).
   - **Mixed** — both. Apply first, then propagate.

4. **Read files in scope** in full, **but skip any file already in
   tool-tracked state from this session** — don't re-read a file you
   just edited. Skip binary files.

5. **Apply procedure** (marker commits):
   - For each `!!` marker: read the instruction text, apply it to the
     target code/text, remove the whole marker comment. Exception:
     markers containing `[keep]` are preserved as-is
   - If the commit subject is `!! <text>`, apply `<text>` globally to
     the committed files
   - Resolve conflicts per protocol rules 1–5

6. **Propagation procedure** (choice commits):
   - Identify the decision: what was added, removed, or replaced
   - Scan each file *in the commit scope* for references that
     contradict the decision (stale branches, removed APIs, old
     behavior descriptions, obsolete rationale)
   - If the decision names a **symbol, path, API, or config key**,
     also `grep` the broader repo — stale references may live outside
     the files the user touched
   - Apply protocol rule 4 (clean up broken surroundings after user
     deletions) even when no propagation is needed elsewhere

7. **Ambiguity check** — if a commit message carries multiple
   instructions, an unusual phrasing, or an edit whose scope is
   unclear, post a one-paragraph interpretation **before** editing.
   If the user doesn't push back within a turn, proceed. This is
   cheaper than committing in the wrong direction and reverting.

8. **Commit each logical change** — one commit per decision, using
   the body template in the protocol. If there is genuinely nothing
   to do (no markers, no propagation, no cleanup), report it and
   exit without creating an empty commit.

## Related

- `/g-intent-squash-archive` — when done iterating, squash the branch
  into one clean commit preserved as a git tag
