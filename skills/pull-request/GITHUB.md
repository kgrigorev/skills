# GitHub

Commands for [`SKILL.md`](SKILL.md) and [`STACKS.md`](STACKS.md) on GitHub, with the `gh` CLI.

## Open and update

- **Default branch:** `gh repo view --json defaultBranchRef -q .defaultBranchRef.name`.
- **Template:** `.github/pull_request_template.md`, or a file in `.github/PULL_REQUEST_TEMPLATE/`.
- **Title rule:** a CI job that checks PR titles, in `.github/workflows/`.
- **Create:** push the branch (`git push -u origin HEAD`), then
  `gh pr create --assignee @me --title "<title>" --body-file -` with the body on stdin.
- **Edit:** `gh pr edit <number> --title "<title>" --body-file -`.
- **PRs based on a branch:** `gh pr list --base <branch> --state open`.

## Merge settings

The methods the repo allows:
`gh repo view --json mergeCommitAllowed,squashMergeAllowed,rebaseMergeAllowed`.

The commit message settings:

```sh
gh api 'repos/{owner}/{repo}' \
  --jq '{squash_merge_commit_title, squash_merge_commit_message, merge_commit_title, merge_commit_message}'
```

A `*_message` of `BLANK` for the method you use is the repo's own choice: leave the message to
GitHub. Any other value, or `null` (the token cannot read the settings), means you pass it.

## Checks

Poll `gh pr checks <n> --json name,state,bucket` and print one table when a conclusion changes.
Exit when no row is pending.

Reviews are required only when branch protection sets `required_pull_request_reviews`:

```sh
gh api repos/{owner}/{repo}/branches/<base>/protection
```

A 404, or a null `required_pull_request_reviews`, means green checks are enough.

## Merge a PR

For a squash merge, pass the PR's title as the subject and its body as the message. GitHub takes
`--subject` verbatim, so add the PR number yourself:

```sh
gh pr merge <number> --squash \
  --subject "$(gh pr view <number> --json title,number -q '"\(.title) (#\(.number))"')" \
  --body "$(gh pr view <number> --json body -q .body)"
```

For a merge commit, use `--merge` with `--body` only so GitHub keeps its `Merge pull request
#<number>...` subject; add `--subject` as above only when `merge_commit_title` is `PR_TITLE`.
When the message is left to GitHub (`BLANK`), run `gh pr merge` without `--subject` and `--body`.
On a branch with a merge queue, follow "Merge queue". Done when `gh pr view <number> --json state`
says `MERGED`.

## Merge queue

A branch has a merge queue when this query returns a value; its `mergeMethod` is the queue's
method:

```sh
gh api graphql -F owner='{owner}' -F name='{repo}' -F branch='<default branch>' \
  -f query='query($owner:String!,$name:String!,$branch:String!){repository(owner:$owner,name:$name){mergeQueue(branch:$branch){configuration{mergeMethod}}}}' \
  --jq .data.repository.mergeQueue
```

The queue sets the method and the merge commit's message. `gh pr merge <number>` only adds the PR
to the queue, and fails when the repo does not allow auto-merge; then add it with
`gh api -X PUT 'repos/{owner}/{repo}/pulls/<number>/merge-async'`. That is the one fallback
endpoint. Either way the merge lands later: poll `state`, `isInMergeQueue` and `autoMergeRequest`
on `repository.pullRequest(number:<number>)` in `gh api graphql` until `state` says `MERGED`
before you move the next PR or delete a branch. When `state` stays `OPEN` with `isInMergeQueue` `false` and `autoMergeRequest` `null` across a
few polls, the queue rejected or dropped the PR: stop and report to the owner. Deleting a PR's
branch before it merges closes the PR.

## Build a stack

Build with `gh stack` whenever `gh extension list` shows it (GitHub then shows the PRs as one
stack and merges them in one step). Start the stack with `gh stack init <first branch>`, which
bases it on the default branch, and commit the first layer. For each further layer,
`gh stack add <branch>` creates the branch on top and checks it out; commit that layer there.
Then run `gh stack submit --open`. To adopt branches you already have, list them bottom to top:
`gh stack init <b1> <b2> <b3>`. After a lower layer changes or merges (`gh stack view` shows
"Needs rebase"): `gh stack rebase`, then `gh stack submit`. Both rewrite pushed branches, so ask
the owner first.

`gh stack submit` without a terminal uses generated titles, leaves new PRs as drafts unless you
pass `--open`, and assigns no one. Fix each PR with
`gh pr edit <number> --add-assignee @me --title "<title>" --body-file -`; a layer's number is
`gh pr view <branch> --json number -q .number`.

Without `gh stack`: cut each branch from the one below and open its PR with
`--base <branch below>`. After changing a lower layer, merge it into each branch above as in
STACKS.md "Build a stack".

## Merge a stack

A stack on GitHub (linked by `gh stack submit` or `gh stack link`) merges only through GitHub's
async merge API: `gh pr merge` and the REST merge endpoint refuse its PRs. Check out the stack's
top branch and run `gh stack merge`. It merges every PR in the stack, all or none, with the
method the repo's rules and settings choose (`--merge`, `--squash` or `--rebase`), and without
a terminal it does not ask. Pass no number: a bare number is read as a stack number first.

```sh
gh stack merge --yes --merge
```

`gh stack merge` takes no commit message, so the repo's commit message settings write it. On a
branch with a merge queue the PRs join the queue. GitHub runs its rules when the merge runs, and
stacked merges cannot bypass them.

Other stacks merge bottom-up, one PR at a time, the top one included.

**With merge commits allowed**, for each layer:

1. Merge it with a merge commit as in "Merge a PR". The PR above already holds the lower
   commits, so once they land its diff shrinks to its own commits with no rewrite.
2. Point the next PR at the default branch with `gh pr edit <next> --base <default branch>`.
   Only then delete the merged branch, with `git push origin --delete <branch>`, unless the repo
   deleted it on merge or open PRs are based on it. Move the PR yourself rather than rely on
   GitHub's retarget; without the move, the next PR merges into the old branch.
3. Poll the next PR's checks as in "Checks", then repeat with it.

**Without merge commits**, land the stack with
[`scripts/land-squash-stack`](scripts/land-squash-stack), lowest PR first, from a clone whose
`origin` holds the PR branches. Run it with `--dry-run` first, then for real in the background:
it waits on each layer's checks, up to an hour each.

```sh
sh <this-skill-dir>/scripts/land-squash-stack --dry-run <pr1> <pr2> <pr3>
sh <this-skill-dir>/scripts/land-squash-stack <pr1> <pr2> <pr3>
```

After each squash it merges the default branch into the next branch with `-s ours`, which
changes no file, so the next diff shrinks to its own commits without a force-push. Before
anything lands it checks that every PR is open and ready, is based on the branch of the PR listed
below it, and holds that PR's head; a fix that was never merged up fails this check. When it
stops, for example because the default branch moved during the run, it says what to fix and
prints the command that continues the run. It squashes with the PR's title and body, or leaves
the message to GitHub when `squash_merge_commit_message` is `BLANK`.

**On a branch with a merge queue**, `land-squash-stack` refuses to run. With `SQUASH`, before
adding the first PR, run `git fetch origin` and check that every branch in the stack holds the
tip of the one below it (`git merge-base --is-ancestor origin/<lower> origin/<upper>`); merge any
missing commits upward first. For each layer, record `<head>` (`git rev-parse origin/<branch>`),
add the PR as in "Merge queue", and wait until it says `MERGED` before you move the next PR as in
step 2 above. With a `mergeMethod` of `MERGE`, wait for `<next>`'s checks and repeat. With
`SQUASH`, run `git fetch origin` and check out `<next branch>` at `origin/<next branch>` before
you add `<next>`: if `git rev-parse origin/<default branch>^{tree} <head>^{tree}` prints one value
twice, run `git merge -s ours --no-edit origin/<default branch>` and push; else if `<squash
commit>^{tree}` (`gh pr view <merged> --json mergeCommit -q .mergeCommit.oid`) equals
`<head>^{tree}`, run `git merge -s ours --no-edit <squash commit>` then
`git merge --no-edit origin/<default branch>`, merge upward and push; else run
`git merge --no-edit origin/<default branch>`, resolve, merge upward and push. Wait for `<next>`'s
checks, then repeat. With `REBASE`, the next PR conflicts with the rewritten commits: tell the
owner, and rebase the rest of the chain only on their OK, since it needs a force-push.

Done when `gh pr view <number> --json state` says `MERGED` for each PR.
