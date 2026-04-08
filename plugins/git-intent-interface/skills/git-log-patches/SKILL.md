---
name: git-log-patches
version: 0.1.1
description: >-
  Show git log with patches (diffs) in reverse order for the last N commits.
  This skill should be used when the user says "show patches", "show last N
  commits with diffs", "git log patches", "review recent diffs", or "show me
  what changed".
argument-hint: <N>
allowed-tools: Bash
---

If `$ARGUMENTS` is empty or not a positive integer, ask the user for the number of commits.

Run the command and display the output:

```bash
git log -p -$ARGUMENTS --reverse
```

## Related skills

- `/g-intent-apply` — process the reviewed commits as instructions
- `/g-intent-reprocess` — propagate choices found in the patches
- `/g-intent-squash-archive` — squash the branch after review
