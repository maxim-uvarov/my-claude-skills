# Git Intent Protocol

Authoritative rules for processing git-intent instructions. Referenced by g-intent-apply (procedural) and g-intent-workflow (documentation).

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
