---
name: g-intent-apply
description: >-
  Process the last N commits as instructions — execute !! markers and commit
  message directives in any file type. This skill should be used when the user
  says "apply intent", "process last N commits", "execute markers", "run git
  intent", "apply !! instructions", "g-intent apply", or "g-intent-apply".
argument-hint: <N>
allowed-tools: Bash, Read, Edit, Write
---

If `$ARGUMENTS` is empty or not a positive integer, ask the user for the number of commits.

Verify the working tree is clean (`git status --porcelain` returns empty). If not, stop and ask the user to commit or stash first.

Protocol rules (commit message patterns, marker syntax, conflict resolution, commit requirements) are in `references/protocol.md`. Follow them exactly.

## Procedure

1. Run `git log -p -$ARGUMENTS --reverse` and display the output
2. Read all changed files in full (skip binary files)
3. Interpret commit messages and markers per the protocol
4. Execute all instructions. For each `!!` marker:
   - Read the instruction text after `!!`
   - Apply it to the code/text at that location
   - Remove the marker line (the entire comment containing `!!`)
   - **Exception:** if the marker contains `[keep]`, preserve it as-is
   - When instructions conflict, apply the conflict resolution rules from the protocol
5. Commit each logical change separately with a descriptive subject and mandatory body explaining the reasoning
