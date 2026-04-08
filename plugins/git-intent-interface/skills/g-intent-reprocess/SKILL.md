---
name: g-intent-reprocess
description: >-
  Propagate a user's choice through files — find and remove or rewrite
  references that conflict with the change the user committed. This skill
  should be used when the user says "reprocess", "propagate choice",
  "propagate my change", "clean up conflicting references",
  "g-intent-reprocess", or "reprocess file".
argument-hint: "[file path | N]"
allowed-tools: Bash, Read, Edit, Write
---

Conflict resolution rules are in the g-intent-apply `references/protocol.md`. Follow them — especially rule 3: the user's committed change is the decision.

## Arguments

- **No argument** — use files changed in the last commit
- **File path** — reprocess that single file using the last commit's diff as context
- **N (integer)** — use files changed in the last N commits

## Procedure

1. Verify the working tree is clean (`git status --porcelain` returns empty). If not, stop and ask the user to commit or stash first
2. Identify the scope:
   - Run `git log -p -N --reverse` (or `-1` if no argument) to get the diff
   - If a file path was given, limit reprocessing to that file but still read the full diff for context
3. For each file in scope, read it in full
4. Analyze the diff to understand what the user chose — what was added, removed, or replaced. This is the decision
5. Scan each file for references that conflict with the decision:
   - Code that assumes the unchosen option (removed branch, deleted API, replaced pattern)
   - Variables, imports, or config entries that only served the removed path
   - Comments or documentation that describe the old behavior
6. If no conflicts found — report that and stop
7. If conflicts found — list them and explain why each conflicts with the user's decision. Ask the user to confirm before making changes
8. Apply the changes: remove or rewrite conflicting references
9. Commit with a subject describing the propagation and a body that explains: what the user's original decision was, which references conflicted, and why they were removed or rewritten
