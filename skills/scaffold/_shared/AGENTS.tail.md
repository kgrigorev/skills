## Writing

For chat replies, commits, PRs, code comments and docs. Many readers are not native English
speakers.

- Short sentences and plain words. Lead with the result. Then what the reader needs to act: what
  changed, what failed, what is left, what you did not verify.
- Say what a technical idea does before you name it.
- A chat reply fits one screen. Use a table for parallel facts and a numbered list for steps.
  Keep every risk and open question.
- Name files by repo-relative path.
- Docs state rules and pointers, never project status. Status goes stale.
- Commits and PRs describe the change only, with no tool or AI attribution.
- PR title: `type(scope): what changed`, at most 72 characters. CI checks it. PR body: fill
  `.github/pull_request_template.md`, one line per slot. One concern per PR, about 200 changed
  lines at most. Open it with `gh pr create --assignee @me`, so the owner is assigned. Stack
  bigger work as PRs whose base is the branch below. Squash merges make the PR title and body the
  commit on `main`.

## Review

Review each PR on its own. Before a stack merges, review it once as a whole for problems between
PRs only:

```sh
git diff $(git merge-base origin/main <top>)..<top>
```
