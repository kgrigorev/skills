---
name: commit-message
description: Write a git commit message. Use whenever you commit.
---

# Commit message

In a squash-merge repo the branch commits vanish at merge, and the PR title and body become the
commit on `main`. So branch commits stay short. The full story goes into the PR body.

1. **Title.** Follow the repo's convention: `AGENTS.md`, a CI title check, or else
   `git log --format=%s -20`. Default: `type(scope): what changed`, at most 72 characters, with
   one of `feat fix docs refactor test build ci chore perf revert`.
2. **Body.** None when the title says it all. Otherwise one sentence on why, then at most four
   one-line points the diff does not show.
3. **No attribution.** No tool or AI credit: no agent `Co-Authored-By` trailer, no "Generated
   with" line. The message describes the change only.

Done when `git log -1 --format=%B` shows a title within the limit and a body within the budget.
