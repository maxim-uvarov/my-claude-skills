# Git Intent Protocol

Git is the instruction interface between human and agent. The human delivers intent through **commit messages**, inline **`!!` markers** in any file type, and in the chat. The agent reads the diff, executes the instructions, and commits the results.

## Why

The main goal is to preserve intent for future LLM sessions, so all commit messages by agents must include motivation.

We rely heavily on git — every change is a commit the human can review, revert, or amend. When in doubt, the agent should make the change and commit rather than ask for confirmation. Git is the review interface.

## Commit Message Protocol

Three patterns:

1. **`!!` alone** — process all `!!` markers in committed files; no additional global instruction
2. **`!! instruction text`** — process markers AND apply the instruction text globally to committed files
3. **Plain message** (no `!!`) with `!!` markers in files — the message is context/explanation, not an instruction; still process all `!!` markers

## Markers

Markers use the native comment syntax of the file's language, prefixed with `!!`. Always single-line. Place on the line above or beside the target code.

When removing a marker, remove the entire comment (including closing delimiters like `*/` or `-->`), not just the `!!` token.

### Lifecycle

- **Default:** all `!!` markers are removed after the agent processes them
- **Exception:** a marker containing `[keep]` is preserved as-is; the `[keep]` keyword stays in the marker; the user removes it manually when ready
- HTML comments without `!!` are preserved — they are persistent context, not instructions

## Conflict Resolution

When instructions contradict each other, apply these rules in order:

1. **File marker overrides commit message** — a marker is more specific (tied to a location); the commit message is general
2. **Later marker overrides earlier marker in the same file** — top-to-bottom processing; if an earlier marker's result is invalidated by a later one, the later one wins
3. **User's committed change overrides prior markers** — if the user edited code that a marker targets, the user's edit is the decision; remove the marker without re-applying it
4. **When ambiguous, stop and ask** — if two instructions conflict and neither is clearly more specific, present both to the user and ask which one to follow

## Agent Commits

- Subject = what changed, body = why
- Each logical change gets its own commit
- Commit body is mandatory — include the instruction that triggered the change and the user's reasoning
- A commit without a body is a loss of context
- A decision visible in git history is binding — do not override without explicit instruction

## General Rules

- Skip binary files in the diff
- After processing: all `!!` markers removed (except `[keep]`), code/text is valid and clean

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
