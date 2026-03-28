---
name: g-intent-apply
description: >-
  Process the last N commits as instructions — execute !! markers and commit
  message directives in any file type. This skill should be used when the user
  says "apply intent", "process last N commits", "execute markers", "run git
  intent", "apply !! instructions", or "g-intent-apply".
argument-hint: <N>
allowed-tools: Bash, Read, Edit, Write
---

If `$ARGUMENTS` is empty or not a positive integer, ask the user for the number of commits.

Verify the working tree is clean (`git status --porcelain` returns empty). If not, stop and ask the user to commit or stash first.

Process the last $ARGUMENTS commits as instructions:

1. Run `git log -p -$ARGUMENTS --reverse` and display the output
2. Read all changed files in full (skip binary files)
3. Interpret the instructions:
   - **Commit message starting with `!!`** — the text after `!!` is a global instruction for the committed files
   - **Commit message `!!` alone** — no global instruction, just process the markers in files
   - **Plain commit message** (no `!!`) — the message is context/explanation, not an instruction; still process any `!!` markers in the files
   - **`!!` markers in files** — specific instructions tied to their location

4. Execute all instructions. For each `!!` marker:
   - Read the instruction text after `!!`
   - Apply it to the code/text at that location
   - Remove the marker line (the entire comment containing `!!`)
   - **Exception:** if the marker contains `[keep]`, preserve it as-is

5. Commit each logical change separately (one commit per marker processed or per coherent edit from the commit message) with a descriptive subject and mandatory body explaining the reasoning

## Marker Recognition

Markers use the native comment syntax of the file's language, prefixed with `!!`.

When removing a marker, remove the entire comment (including closing delimiters like `*/` or `-->`), not just the `!!` token.

## Rules

- Markers are always single-line
- After processing: all `!!` markers removed (except `[keep]`), code/text is valid and clean
- HTML comments without `!!` are preserved — they are persistent context, not instructions
- Each change gets its own commit
- Commit body must include what instruction triggered the change
- A decision visible in git history is binding — do not override without explicit instruction
- Skip binary files in the diff
