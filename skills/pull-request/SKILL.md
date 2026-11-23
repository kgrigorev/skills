---
name: pull-request
description: Open, update or merge a GitHub pull request or GitLab merge request. Use when you open or merge a PR or MR, edit its title or description, push fixes for review findings, split work into stacked PRs, or review a stack of PRs.
---

# Pull request

A PR here is a GitHub pull request or a GitLab merge request (MR). The PR body is the lasting
record of why the change exists (the merge puts it on the default branch), and reviewers skim it.
Keep it short.

## Platform

Before the first command, find the platform and read its file: [`GITHUB.md`](GITHUB.md) or
[`GITLAB.md`](GITLAB.md). `GH_HOST` names GitHub; `GITLAB_HOST`, `GL_HOST` or `GITLAB_URI` names
GitLab. Otherwise the host in `git remote get-url origin` decides: `github.com`, `*.github.com`
and `*.ghe.com` are GitHub; `gitlab.com` and `*.gitlab.com` are GitLab. For any other host, run
`gh auth status --hostname <host>` and `glab auth status --hostname <host>`, or (when an SSH
alias hides the API host) `gh repo view` and `glab repo view`; the one that exits 0 names the
platform. When neither does, ask the owner. Done when you have read the platform file; it holds
every `gh` and `glab` command.

## Open a PR

1. **Scope.** One concern, about 200 changed lines, at most about 20 files. Count with
   `git diff --stat -C --diff-filter=d origin/<base>...HEAD`, where the base is the default
   branch, or the branch below in a stack: added plus deleted lines, tests included. Pure
   deletions (`--diff-filter=d`), moves and copies (`-C`) already count as zero; leave generated
   files and lockfiles out with `':!<path>'` pathspecs. A PR may grow to 300 lines to keep one
   concern whole; only its own tests take it past 300. Split a PR that spreads over several
   unrelated directories, whatever its size. For bigger work read [`STACKS.md`](STACKS.md) and
   split it. Done when each PR is one concern within the budget.
2. **Template.** Read the repo's PR template now, even if you read it earlier; the platform file
   says where it lives. It is the format. Fill its slots in order and add no sections. Without a
   template, write three short paragraphs of prose:

   ```
   <what the PR does, starting with a verb: "Adds ...", "Makes ...", "Splits ...">

   <why it should exist: the problem it solves or the value it adds>

   <what a reviewer needs beyond the diff: how you checked it, a risk that is not obvious,
   anything you did not verify>
   ```

3. **Title.** Follow the repo's convention: `AGENTS.md`, a CI title check, a title rule in the
   platform's settings, or else `git log --format=%s -20`. Default: `type(scope): what changed`,
   at most 72 characters.
4. **Body.** Write for a human who reads it once, in **plain** words: say what changes for the
   people who use the code ("Every test file runs, wherever it is"), rather than which settings
   or flags moved. Each paragraph is one or two sentences, and a template slot holds one line
   unless the template gives it its own limit, such as a sketch of at most 10 lines. State the
   reason in general terms, as it will still read after the merge, rather than the story of how
   the need came up. Leave out what the diff and the repo's files already show: file lists (name
   a file only when the reader must find it), code, renames, lists of details. Use a bullet list
   only for a real list of parallel items. Then reread it and delete every sentence a reviewer
   would not miss. Done when the body is about 60 to 100 words and each slot is within its
   limit.
5. **Create.** Push the branch and open the PR with the platform file's create command, assigned
   to you, with the body on stdin. No tool or AI attribution. Report the URL.

## Update a PR

Before you push commits that fix review findings, review the commits since the last reviewed one
against those findings. Rerun the review that found them when an agent ran it (its skill or
reviewer subagent, given the findings); otherwise review the range yourself. Done when each
finding is resolved and the range raises no new one.

After new commits, check that the title and body still match the diff. Fix them with the
platform file's edit command, under the same rules.

## Merge a PR

Merge only when the owner asks. The repo's merge rules come first: its PR doc, `AGENTS.md` or
contributing guide, and the methods its settings allow (the platform file shows how to read
them). Reviews are required only when the base branch's protection sets
`required_pull_request_reviews` (the platform file shows how to read it). A missing protection
document or a null field means green checks are enough. Poll the platform's checks and print one
table when a conclusion changes. Exit when no row is pending.

Without rules, squash a PR that was never part of a stack. A stacked PR (its base is another
branch, or another open PR targets its branch) merges by [`STACKS.md`](STACKS.md), and so does
the rest of its stack once the lower layers land. When the platform refuses a merge, report its
message.

Pass the PR's body (and its title where the platform file says to) as the merge commit's message.
Leave the message to the platform when the repo's docs say to, when the project sets its own
commit message template, or when the merge path takes no message (the platform file names those).
Done when the platform shows the PR as merged.

## Stacks

To build, update, review or merge a stack of PRs, read [`STACKS.md`](STACKS.md).
