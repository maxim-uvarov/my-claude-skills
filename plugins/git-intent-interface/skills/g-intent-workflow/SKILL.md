---
name: g-intent-workflow
description: >-
  On-demand knowledge about the git-intent methodology. This skill should be
  used when the user asks about "git intent workflow", "!! markers", "how to
  use git-intent", "marker syntax", "commit message protocol", or "how does
  git intent work".
---

# Git Intent Interface

A workflow where git is the instruction interface between human and agent. The human delivers intent through channels: **commit messages**, inline **`!!` markers** in any file type, and in the chat. The agent reads the diff, executes the instructions, and commits the results.

## Why

The main goal is to preserve intent for future LLM sessions, so all commit messages by agents must include motivation.

We rely heavily on git — every change is a commit the human can review, revert, or amend. When in doubt, the agent should make the change and commit rather than ask for confirmation. Git is the review interface.

All skills are in the initial prototyping phase — this is guidance, not strict rules. We are inventing mechanics along the way.

## Commit Message Protocol

- `!!` — process all markers in the committed files, no additional instruction
- `!! instruction text` — process markers AND apply the instruction globally to committed files
- A plain commit message (no `!!`) with `!!` markers in files — the commit message is context/explanation, markers are the instructions

## Instruction Channels

- **Commit message** — high-level instruction (`!! check consistency`, `!! add error handling`)
- **`!!` markers in files** — specific actions tied to a location in the file

Both are ephemeral by default — commit messages are read and executed, markers are removed after processing.

## Markers

Markers use the native comment syntax of each language, prefixed with `!!`. They are always single-line. Place the marker on the line above or beside the target code.

**Default:** all `!!` markers are removed after the agent processes them.

**Exception:** a marker containing `[keep]` is preserved:

```python
#!! [keep] revisit after v2
def legacy_handler():
    ...
```

The `[keep]` keyword itself stays in the marker. The user removes it manually when ready.

## Git Commits (Agent)

Subject = what changed, body = why. Diff shows how.

- Each logical change gets its own commit
- Commit body is mandatory — include the user's reasoning, the instruction that triggered the change, and any rejected alternatives
- A commit without a body is a loss of context

## Workflow

1. Edit any file — code, markdown, config, etc.
2. Add `!!` markers as inline instructions where needed
3. `git commit` — the commit message is either `!!` (just process markers) or `!! additional instruction`
4. Invoke `/g-intent-apply N`
5. Agent reads the diff, processes markers and commit message, commits each change separately
6. Review with `/git-log-patches N` or `git log -p`

## Available Commands

- `/g-intent-apply N` — process last N commits as instructions
- `/g-intent-squash-archive` — squash all branch commits, preserve history in a git tag
- `/git-log-patches N` — show `git log -p --reverse` for last N commits
