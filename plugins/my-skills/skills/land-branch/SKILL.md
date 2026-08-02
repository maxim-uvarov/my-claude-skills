---
name: land-branch
description: Land a finished branch on the trunk as one clean commit — squash it, archive the original history in a tag, keep `todo/` and `gi/` out of the trunk, then merge. Pass `--grouped` for a branch that holds several unrelated changes: it becomes a few commits by topic, merged with `--no-ff`. Use when the user says "land the branch", "land this", "merge to main", "finish this branch", or "squash and merge".
argument-hint: [--grouped] [trunk branch, if not main/master]
allowed-tools: Bash(git *)
---

A working branch carries rollback points: half-finished steps, reversed decisions, "wip", "fix typo". That is what they are for while the branch is alive. The moment it lands they become noise — a later agent reading `git log` on the trunk wades through abandoned attempts instead of real history, and that noise fills its context.

So the branch lands as **one commit**, its full history survives in a tag, and the working material (`todo/`, `gi/`) never reaches the trunk at all. When the branch really holds several unrelated changes, one commit would lie about being atomic — that is what `--grouped` is for, at the end of this file.

The tag is insurance against the squash: `reset --soft` makes the original commits unreachable, and the tag is what keeps them. When the branch is already a single commit there is no squash, that commit lands on the trunk untouched, and a tag pointing at it preserves nothing that the trunk does not already hold. Then no tag is written.

## Authorization

The global rule is that the agent never merges on its own initiative, because a merge touches the trunk. **This skill is the named exception.** The user invoking `/land-branch` *is* the authorization — that is not inference. So do not stop one command short and hand back a merge command to paste.

What the exception buys is one confirmation, not silence: show the whole plan at step 8, wait, then run it. Everything before that stop is read-only.

Two things stay off-limits even here: **never push**, and never run this on the trunk itself.

## Procedure

Steps 1–8 only read. Nothing is changed until the user confirms.

1. **Branch guard.** `git branch --show-current`. If it returns `main` or `master` — **stop immediately** and say so. Do not continue.

2. **Clean-tree check.** `git status --porcelain` must be empty. If not, stop and ask the user to commit or stash. A soft reset would otherwise sweep unrelated edits into the landing commit.

3. **Find the trunk.** Strip `--grouped` out of `$ARGUMENTS` first — it selects the mode, not a branch. What remains is the trunk name if given, else `main`, else `master` (`git rev-parse --verify <name>`).

4. **Find the base.** `git merge-base <trunk> HEAD`. Then `git log --oneline <base>..HEAD` — if empty, report "nothing to land" and exit.

5. **Has the trunk moved?** Compare `git rev-parse <trunk>` with `<base>`. If they differ, the trunk advanced and `--ff-only` will fail. The plan then gains a `git rebase <trunk>` between the squash and the merge — one commit to replay, but say plainly that a conflict there needs the user's hands. Never substitute a merge commit for the rebase without saying so.

6. **Read the history for the message.** `git log <base>..HEAD` with full bodies. This is the part that must not be lost: why this approach, why an alternative was rejected, what the user said. Drop only the mechanics. If the branch has a `gi/` canvas or the current session holds reasoning that never reached a commit body, pull it in here — the tag preserves the old bodies, but only this commit is read on the trunk.

   **No run status in the body.** Lines like `235 tests passed`, `all checks green`, `verified with nutest` do not belong in the commit message. They were true at one moment on one tree; on the trunk they are unverifiable and often already false. Report them in the chat reply, where the user reads them while they still mean something. The body carries *why*, not *it worked*.

7. **Find the working material.** `git diff --name-status <base>..HEAD -- todo/ gi/`. Keep the status letters; they decide what the working tree looks like afterwards (step 11).

8. **Judgement, then STOP.** Two calls to make first:
   - Already one clean commit with a good body? Then there is nothing to squash — skip straight to the merge (step 13). No `reset --soft`, no new commit, no `Archive:` trailer, and **no archive tag**.
   - Does the branch really hold two unrelated changes? Then propose two commits, not one. Follow the letter here and you ship a commit that lies about being atomic. Say so even when the user did not pass `--grouped`: the mode is theirs to choose, but the observation is yours to make.

   Show the user, in one block: the commits being squashed, the generated message, the `todo/`/`gi/` paths being dropped, an `archive/<branch>` overwrite warning if `git tag -l` finds one, the rebase warning from step 5, and the exact merge command. **Wait for confirmation.**

## Landing

9. **Archive first** — only on the squash path. `git tag -f archive/<branch> HEAD`. This runs before anything destructive, and it is what makes the rest reversible — every original commit, including the `todo/` ones, stays reachable. Skip it entirely when step 8 sent you to the merge: there is nothing to make reachable.

10. **Squash.** `git reset --soft <base>`. The whole branch is now staged as one change.

11. **Drop the working material.** For the paths found in step 7: `git restore --staged -- <paths>`. Only pass paths that actually appear there; a pathspec matching nothing is an error.

    This is the whole `todo/`/`gi/` mechanism — no filtering, no history rewrite, one command at the one moment it is natural. What it leaves behind depends on the status letter, and you must **report** the leftovers rather than claim a clean tree:
    - `A` (added on the branch) → the file becomes untracked. This is the normal case, and exactly where a parked note belongs.
    - `M` (modified) → the change stays in the working tree, unstaged.
    - `D` (deleted) → the file is missing from disk while the index holds it back; shows as an unstaged deletion.

    A note this branch **finished** is not parked any more — it is done. Say so at step 14 and offer to delete it, instead of leaving it in the working tree where the next session reads it as open work. Same for a `gi/` canvas whose thread closed with this branch. Judge each file: only the ones this branch actually resolved — a branch often adds a note about something it did not fix, and that one stays. The archive tag holds every one of them, so deleting loses nothing.

    Then check `git diff --cached --quiet`: if nothing is staged any more, the branch held *only* working material. Report that and stop — there is nothing to land.

12. **Commit** with the message from step 6, plus an `Archive: archive/<branch>` trailer.

13. **Merge.** `git switch <trunk>` then `git merge --ff-only <branch>`. With the rebase from step 5 if the trunk moved.

14. **Report**, briefly: the trunk's new commit, that the user is now standing on `<trunk>` (say it plainly — the next edit would otherwise land there), and — if step 9 ran — that `git log archive/<branch>` still holds the full history. Split the leftover working-tree state from step 11 into notes still open and artifacts this branch completed; for the completed ones give the `rm` command (`allowed-tools` here is git only, so the user runs it). This is also where run status belongs — `nutest run` → `57 passed`, not in the commit body. Do not push, and do not delete the branch — offer both as commands if the user wants them.

## Grouped mode (`--grouped`)

Some branches are not one change with rollback points — they are a long session that touched several unrelated things. Step 8 already tells you to propose two commits when the branch holds two changes; `--grouped` is that same call grown large, with a mechanism to carry it out.

The trade-off is explicit, and the user takes it on when they pass the flag: the group commits **do** reach the trunk, so `git log <trunk>` shows them all. `git log --first-parent <trunk>` is the clean view. That means the merge commit is what a later reader lands on — its body, not the group bodies, must carry the reasoning that has to survive.

Steps 1–7 and 9 run unchanged. The archive tag still matters: `reset --soft` makes the original commits unreachable here too.

### Grouping is by path

After step 6, build the groups. `git log --name-only <base>..HEAD` gives each commit's paths; a group is the commits that touch the same area for the same reason.

There is no hunk splitting in this skill — `rebase -i` is not available and hand-editing hunks is the user's job, not yours. So a file that appears in two candidate groups **cannot** be split: merge those two groups into one and name that file as the reason in the step 8 plan. Never let a file land in one group while its other change silently disappears — that ships a commit that does not build.

### Steps 10–12, replaced

- `git reset --soft <base>` — the whole branch is staged, as in step 10.
- `git restore --staged .` — unstage all of it. The working tree is untouched.
- Per group: `git add <the group's paths>`, then `git commit` with that group's message.
- `todo/` and `gi/` are never added, so step 11's `git restore --staged` has nothing to do and disappears — the same result reached by doing nothing. What they leave behind in the working tree, and your duty to report it instead of claiming a clean tree, is exactly as step 11 describes.
- If every group comes out empty, the branch held only working material. Report that and stop, as step 11 says.

### Step 13, replaced

`git switch <trunk>`, then `git merge --no-ff <branch>`. Write the step 6 reasoning summary and the `Archive: archive/<branch>` trailer into the **merge commit's** body.

`--no-ff` merges a diverged trunk by itself, so the step 5 rebase is not needed. A conflict is still possible, and it still needs the user's hands.

Step 14 gains one line: `git log --first-parent <trunk>` hides the group commits.

## Related

- `/git-intent-squash-archive` — the same shape, but inside the gi loop: it squashes and archives a canvas branch and stops there, without merging. Reach for it when the branch is gi working material; reach for `land-branch` for ordinary development.
