---
name: pull-request
description: Open, update or merge a GitHub pull request. Use when you open or merge a PR, edit its title or description, split work into stacked PRs, or review a stack of PRs.
---

# Pull request

The PR body is the lasting record of why the change exists (a squash merge makes the title and
body the commit on `main`), and reviewers skim it. Keep it short.

## Open a PR

1. **Scope.** One concern, about 200 changed lines: `git diff --stat origin/main...HEAD`. For
   bigger work read [`STACKS.md`](STACKS.md) and split it. Done when each PR is one concern
   within the budget.
2. **Template.** Read the repo's PR template now, even if you read it earlier:
   `.github/pull_request_template.md`, or a file in `.github/PULL_REQUEST_TEMPLATE/`. It is the
   format. Fill its slots in order and add no sections. Without a template, write three short
   paragraphs of prose:

   ```
   <what the PR does, starting with a verb: "Adds ...", "Makes ...", "Splits ...">

   <why it should exist: the problem it solves or the value it adds>

   <what a reviewer needs beyond the diff: how you checked it, a risk that is not obvious,
   anything you did not verify>
   ```

3. **Title.** Follow the repo's convention: `AGENTS.md`, a CI title check, or else
   `git log --format=%s -20`. Default: `type(scope): what changed`, at most 72 characters.
4. **Body.** Write for a human who reads it once. Each paragraph is one or two plain sentences,
   and a template slot holds one line unless the template gives it its own limit, such as a
   sketch of at most 10 lines. State the reason in general terms, as it will still read after
   the merge, rather than the story of how the need came up. Leave out what the diff and the
   repo's files already show: file lists, code, renames, lists of details. Use a bullet list
   only for a real list of parallel items. Then reread it and delete every sentence a reviewer
   would not miss. Done when the body is about 60 to 100 words and each slot is within its
   limit.
5. **Create.** `gh pr create --assignee @me --title "<title>" --body-file -` with the body on
   stdin. No tool or AI attribution. Report the URL.

## Update a PR

After new commits, check that the title and body still match the diff. Fix them with
`gh pr edit <number> --title "<title>" --body-file -`, under the same rules.

## Merge a PR

Merge only when the owner asks, with the checks green and the reviews in. The repo's own merge
rules come first: its PR doc, `AGENTS.md` or contributing guide, and the methods its settings
allow (`gh repo view --json mergeCommitAllowed,squashMergeAllowed,rebaseMergeAllowed`).

Without rules, squash a PR that was never part of a stack. A stacked PR (its base is another
branch, or another open PR targets its branch) merges by [`STACKS.md`](STACKS.md), and so does
the rest of its stack once the lower layers land. When GitHub refuses a merge, report its
message.

## Stacks

To build, update, review or merge a stack of PRs, read [`STACKS.md`](STACKS.md).
