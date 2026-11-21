# Stacked PRs

A stack is a chain of PRs, each based on the branch below it. Every layer stays one concern and
small, and reviewers read them in order.

## Build a stack

Slice by dependency: each layer must build and pass the checks on its own. Mechanical bulk
(moves, copies, generated files) goes in its own layer.

A rebase rewrites branches you already pushed, so the next push is a force-push. Before you push
a rebased branch (`gh stack submit` or `git push --force-with-lease`), ask the owner. Some agent
harnesses block force-push; then report the commands and let the owner run them.

- Build with `gh stack` whenever `gh extension list` shows it (GitHub then shows the PRs as one
  stack and merges them in one step): `gh stack add` for each layer, then `gh stack submit`. To
  adopt branches you already have, list them bottom to top:
  `gh stack init <b1> <b2> <b3>`. After a lower layer changes or merges (`gh stack view` shows
  "Needs rebase"): `gh stack rebase`, then `gh stack submit`.
- Without it: cut each branch from the one below and open its PR with
  `--base <branch below>`. After changing a lower layer, merge it into each branch above, bottom
  up, and push: no force-push, so no owner approval. Rebase and `--force-with-lease` instead only
  when the owner wants a linear history.

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

Without merge commits, land the stack with [`scripts/land-squash-stack`](scripts/land-squash-stack),
lowest PR first, from a clone whose `origin` holds the PR branches. Run it with `--dry-run` first,
then for real in the background: it waits on each layer's checks, up to an hour each.

```sh
sh <this-skill-dir>/scripts/land-squash-stack --dry-run <pr1> <pr2> <pr3>
sh <this-skill-dir>/scripts/land-squash-stack <pr1> <pr2> <pr3>
```

After each squash it merges `main` into the next branch with `-s ours`, which changes no file, so
the next diff shrinks to its own commits without a force-push. Before anything lands it checks
that every PR is open and ready, is based on the branch of the PR listed below it, and holds that
PR's head; a fix that was never merged up fails this check. Each squash waits until GitHub reports
the PR mergeable and no reported check is pending or failing. When it stops, for example because
`main` moved during the run, it says what to fix and prints the command that continues the run.

On a branch with a merge queue (`gh api repos/{owner}/{repo}/rules/branches/main` lists a
`merge_queue` rule), the queue sets the method and the merge commit's message, and
`land-squash-stack` refuses to run. Add one PR at a time: `gh pr merge` only adds it to the queue,
and fails when the repo does not allow auto-merge; then add it with
`gh api -X PUT repos/{owner}/{repo}/pulls/<number>/merge-async`. Either way the merge lands later:
wait until the PR says `MERGED` before you move the next PR and delete the branch. Deleting a
PR's branch before it merges closes the PR. With a `merge_method` of `MERGE`, nothing else is
needed. With `SQUASH`, do what the script does before you add the next PR: check that `main`'s
files equal the merged PR's head (`git rev-parse origin/main^{tree} <head>^{tree}` prints one
value twice), then `git merge -s ours origin/main` into the next branch and push.

Done when `gh pr view <number> --json state` says `MERGED` for each PR. For any other refusal
(failing checks, a missing review, a ruleset), report GitHub's message. Do not retry through another
endpoint.

## Review a stack

Review each PR on its own. A reviewer of one layer, such as a session or subagent given one PR,
pushes fixes only to that PR's branch and leaves merging and new PRs to whoever owns the stack.
Its last reply lists each finding with what it did about it. The stack's owner then merges each
changed branch into the ones above it, bottom up, before the stack lands; `land-squash-stack`
refuses a stack where a branch lacks the head of the one below. Before the stack merges, review it
once as a whole, for problems between PRs only. The range runs from the merge base with `main` to
the top branch. Leave vendored files out with `':!<path>'` pathspecs:

```sh
git diff $(git merge-base origin/main <top>)..<top>
```
