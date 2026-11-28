---
name: settle-stack
description: Use when a stack of open PRs for one ticket needs independent agent reviews, fixes and a clean merge, and the owner does not read each layer. Triggers - settle, babysit, or review and merge a PR stack. Skip for one PR and for building a stack.
---

# Settle a stack

You coordinate. Reviewers and fixers are fresh subagents; you keep their short replies, not their
reports. Read the `pull-request` skill first (`STACKS.md` and the platform file) and the repo's PR
doc: they own merge-up, checks and the merge method.

## 1. Order the stack

`gh pr list --state open --json number,url,baseRefName,headRefName`; follow base branches up from
the default branch. Done when you hold the PR URLs bottom to top, each based on the one below.
A broken chain stops you: report it.

## 2. Round

Run review, address and merge up. Repeat until a round is clean (step 3), for at most 3 rounds,
then run one last review.

**Review.** One fresh `general-purpose` subagent per PR, in parallel, each in its own worktree:

```
/requesting-code-review thoroughly and critically review <PR URL> as a whole. Provide your
detailed feedback on the PR. Post it as one PR comment (`gh pr comment <n> --body-file -`)
with no tool or model names. Reply with the comment URL and the count of Critical and
Important findings.
```

From round 2, review only PRs whose head moved since their last clean review, and append:
`Earlier feedback and replies are comments on the PR. Review the commits since <sha>, the head
that PR's last review saw. Replay each rebuttal's evidence and say if you accept it (finding
closed) or reject it (finding open).`

**Address.** For each PR with an open Critical or Important finding, bottom up, one at a time,
a fresh subagent in its own worktree:

```
/receiving-code-review evaluate the feedback on <PR URL> and address it. Push fixes to that
PR's branch only. Post one PR comment that lists each finding as fixed, rebutted (with
evidence a reviewer can replay), deferred, or belonging to a lower PR (say which).
```

The next round's review covers the pushed commits, so the fixer starts no reviewer. Pass a
finding that belongs to a lower PR to that PR's fixer. After each fixer, merge its branch into
the one above, push, and go on (`STACKS.md` "Build a stack"). Done when every PR with an open
finding has a reply and every PR contains the branch below it.

## 3. Settled

A round is clean when its reviewers leave no Critical or Important finding open. A fresh reviewer
rules on each rebuttal; you do not. Stop at the first clean round. Findings still open after the
last review: merge nothing, and report each open finding with its PR to the owner.

## 4. Whole stack

One fresh reviewer, for problems between PRs only (`STACKS.md` "Review a stack"), who posts each
problem as a comment on the PR that owns it. Fix each problem in that layer with the address
step, and merge up. Then one fresh reviewer
checks only those fix commits. Done when that check finds nothing open and the repo's check
command is green on the top branch; otherwise merge nothing and report.

## 5. Merge

Merge as `pull-request` says (its platform file, or the repo's PR doc). Done when the platform
shows every PR as merged. Report the PRs merged, the rebuttals accepted and the Minor findings
left.
