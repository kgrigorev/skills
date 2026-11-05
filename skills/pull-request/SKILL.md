---
name: pull-request
description: Open or update a GitHub pull request. Use when you open a PR, edit its title or description, or split work into stacked PRs.
---

# Pull request

With squash merges the PR title and body become the commit on `main`. The body is the lasting
record of why the change exists, and reviewers skim it. Keep it short.

## Open a PR

1. **Scope.** One concern, about 200 changed lines: `git diff --stat origin/main...HEAD`. For
   bigger work read [`STACKS.md`](STACKS.md) and split it. Done when each PR is one concern
   within the budget.
2. **Template.** Read the repo's PR template now, even if you read it earlier:
   `.github/pull_request_template.md`, or a file in `.github/PULL_REQUEST_TEMPLATE/`. It is the
   format. Fill its slots in order and add no sections. Without a template, use:

   ```
   <one sentence: why this change exists>

   - <up to 6 one-line points the diff does not make obvious>
   - Test: <the test that was red before and is green now>
   - Risk: <easy to undo or not, and what it can break>
   - Not verified: <what you did not check; delete the line when you checked everything>
   ```

3. **Title.** Follow the repo's convention: `AGENTS.md`, a CI title check, or else
   `git log --format=%s -20`. Default: `type(scope): what changed`, at most 72 characters.
4. **Body.** Every slot holds one line. Leave out what the diff shows: file lists, code, renames.
   Then reread it and delete every line a reviewer would not miss. Done when each point is one
   line and the body fits one screen.
5. **Create.** `gh pr create --assignee @me --title "<title>" --body-file -` with the body on
   stdin. No tool or AI attribution. Report the URL.

## Update a PR

After new commits, check that the title and body still match the diff. Fix them with
`gh pr edit <number> --title "<title>" --body-file -`, under the same rules.
