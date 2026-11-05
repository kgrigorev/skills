# Stacked PRs

A stack is a chain of PRs, each based on the branch below it. Every layer stays one concern and
small, and reviewers read them in order.

## Build a stack

Slice by dependency: each layer must build and pass the checks on its own. Mechanical bulk
(moves, copies, generated files) goes in its own layer.

- With `gh stack` (`gh extension install github/gh-stack`): `gh stack add` for each layer, then
  `gh stack submit`. After changing a lower layer: `gh stack rebase`, then `gh stack submit`.
- Without it: cut each branch from the one below and open its PR with
  `--base <branch below>`. After changing a lower layer, rebase the branches above onto it and
  push with `--force-with-lease`.

Each body names the PR below it in one point: `Depends on #<number>.` When the bottom PR merges
and its branch is deleted, GitHub moves the next PR's base to `main`.

## Review a stack

Review each PR on its own. Before the stack merges, review it once as a whole, for problems
between PRs only. The range runs from the merge base with `main` to the top branch. Leave
vendored files out with `':!<path>'` pathspecs:

```sh
git diff $(git merge-base origin/main <top>)..<top>
```
