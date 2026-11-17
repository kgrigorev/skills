# Stacked PRs

A stack is a chain of PRs, each based on the branch below it. Every layer stays one concern and
small, and reviewers read them in order.

## Build a stack

Slice by dependency: each layer must build and pass the checks on its own. Mechanical bulk
(moves, copies, generated files) goes in its own layer.

A rebase rewrites branches you already pushed, so the next push is a force-push. Before you push
a rebased branch (`gh stack submit` or `git push --force-with-lease`), ask the owner. Some agent
harnesses block force-push; then report the commands and let the owner run them.

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
async merge API: the other merge APIs, which `gh pr merge` uses, refuse stacked PRs. Use
`gh stack merge` on a branch of the stack. It merges the whole stack, all or none, with the
method the repo allows (`--merge` when merge commits are allowed, else `--squash`), and without
a terminal it does not ask:

```sh
gh stack merge --yes --merge
```

Pass it no number: a bare number is read first as a stack number, so a PR number can merge
another stack. To merge only the lower part, call the API on the highest PR to merge, with the
same method (`squash` without merge commits). It merges that PR and every PR below it:

```sh
gh api -X PUT repos/{owner}/{repo}/pulls/<number>/merge-async -f merge_method=merge
```

While its `status` is `pending`, poll
`gh api repos/{owner}/{repo}/pulls/<number>/merge-async/<details.uuid>`; `failed` carries the
reason. On a branch with a merge queue the PRs join the queue, which sets the method: leave out
`--merge` and `merge_method`. Done when `gh pr view <number> --json state` says `MERGED`.
GitHub runs its rules when the merge runs, and stacked merges cannot bypass them.

Other stacks merge bottom-up, one PR at a time, each layer the same way, the top one included.
With merge commits allowed (`gh repo view --json mergeCommitAllowed`), use one per layer. The PR
above already holds the lower commits, so once they land on `main` its diff shrinks to its own
commits with no rewrite. Keep the PR body as the merge commit's body:

```sh
gh pr view <number> --json body -q .body |
  gh pr merge <number> --merge --delete-branch --body-file -
```

Deleting the branch is what moves the next PR's base to `main`. Before the next merge, check
that `gh pr view <next> --json baseRefName` says `main`.

Without merge commits, squash each layer. The PR above still holds the old lower commits, so its
diff against `main` shows them again. Rebase it before it merges:
`git rebase --onto origin/main <old lower branch> <branch>`. Then push as in "Build a stack".

For any refusal (failing checks, a missing review, a ruleset), report GitHub's message. Do not
retry through another endpoint.

## Review a stack

Review each PR on its own. Before the stack merges, review it once as a whole, for problems
between PRs only. The range runs from the merge base with `main` to the top branch. Leave
vendored files out with `':!<path>'` pathspecs:

```sh
git diff $(git merge-base origin/main <top>)..<top>
```
