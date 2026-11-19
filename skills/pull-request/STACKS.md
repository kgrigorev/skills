# Stacked PRs

A stack is a chain of PRs, each based on the branch below it. Every layer stays one concern and
small, and reviewers read them in order.

## Build a stack

Slice by dependency: each layer must build and pass the checks on its own. Mechanical bulk
(moves, copies, generated files) goes in its own layer.

A rebase rewrites branches you already pushed, so the next push is a force-push. Before you push
a rebased branch (`gh stack submit` or `git push --force-with-lease`), ask the owner. Some agent
harnesses block force-push; then report the commands and let the owner run them.

Run `gh extension list` first. When it shows `gh stack`, build with it: GitHub then shows the
PRs as one stack and merges them as one.

- With `gh stack` (`gh extension install github/gh-stack`): `gh stack add` for each layer, then
  `gh stack submit`. To adopt branches you already have, list them bottom to top:
  `gh stack init <b1> <b2> <b3>`. After a lower layer changes or merges (`gh stack view` shows
  "Needs rebase"): `gh stack rebase`, then `gh stack submit`.
- Without it: cut each branch from the one below and open its PR with
  `--base <branch below>`. After changing a lower layer, rebase the branches above onto it and
  push with `--force-with-lease`.

`gh stack submit` without a terminal works like `--auto`: it uses generated titles and opens new
PRs as drafts. Pass `--open` to make new and existing PRs ready for review. Either way, fix each
generated title and body with `gh pr edit`.

Each body names the PR below it in one line: in the format the repo's PR doc sets, else
`Depends on #<number>.`

## Merge a stack

A stack on GitHub (linked by `gh stack submit` or `gh stack link`) merges only through GitHub's
async merge API: `gh pr merge` and the REST merge endpoint refuse its PRs. Use `gh stack merge`
with the highest PR to merge. It merges that PR and every PR below it, all or none, with the
method the repo allows (`--merge` when merge commits are allowed, else `--squash`), and without
a terminal it does not ask:

```sh
gh stack merge <number> --yes --merge
```

On a branch with a merge queue the PRs join the queue, which sets the method. GitHub runs its
rules when the merge runs, and stacked merges cannot bypass them.

Other stacks merge bottom-up, one PR at a time, each layer the same way, the top one included.
With merge commits allowed (`gh repo view --json mergeCommitAllowed`), use one per layer. The PR
above already holds the lower commits, so once they land on `main` its diff shrinks to its own
commits with no rewrite. Keep the PR body as the merge commit's body:

```sh
gh pr view <number> --json body -q .body | gh pr merge <number> --merge --body-file -
```

Then point the next PR at `main` with `gh pr edit <next> --base main`, and only then delete the
merged branch. Deleting a branch closes the PRs based on it; only the repo's own delete-on-merge
setting moves them to `main` instead. Without the move, the next PR merges into the old branch.

Without merge commits, squash each layer and move the next PR to `main` the same way. It still
holds the old lower commits, so its diff against `main` shows them again. Rebase it before it
merges: `git rebase --onto origin/main <old lower branch> <branch>`. Then push as in "Build a
stack".

On a branch with a merge queue (`gh api repos/{owner}/{repo}/rules/branches/main` lists a
`merge_queue` rule), the queue sets the method and the merge commit's message; follow the
merge-commit or squash steps by its `merge_method`. `gh pr merge` only adds the PR to the queue,
and fails when the repo does not allow auto-merge; then add it with
`gh api -X PUT repos/{owner}/{repo}/pulls/<number>/merge-async`. Either way the merge lands later:
wait until the PR says `MERGED` before you move the next PR and delete the branch. Deleting a
PR's branch before it merges closes the PR.

Done when `gh pr view <number> --json state` says `MERGED` for each PR. For any other refusal
(failing checks, a missing review, a ruleset), report GitHub's message. Do not retry through another
endpoint.

## Review a stack

Review each PR on its own. Before the stack merges, review it once as a whole, for problems
between PRs only. The range runs from the merge base with `main` to the top branch. Leave
vendored files out with `':!<path>'` pathspecs:

```sh
git diff $(git merge-base origin/main <top>)..<top>
```
