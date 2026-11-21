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

The methods the repo allows: `gh repo view --json mergeCommitAllowed,squashMergeAllowed,rebaseMergeAllowed`.

The commit message settings:

```sh
gh api repos/{owner}/{repo} \
  --jq '{squash_merge_commit_title, squash_merge_commit_message, merge_commit_title, merge_commit_message}'
```

A `*_message` of `BLANK` for the method you use is the repo's own choice: leave the message to
GitHub. Any other value, or `null` (the token cannot read the settings), means you pass it.

## Merge a PR

Pass the PR's title as the subject and its body as the message. GitHub takes `--subject`
verbatim, so add the PR number yourself:

```sh
gh pr merge <number> --squash \
  --subject "$(gh pr view <number> --json title,number -q '"\(.title) (#\(.number))"')" \
  --body "$(gh pr view <number> --json body -q .body)"
```

For a merge commit, use `--merge` in place of `--squash`. When the message is left to GitHub,
run it without `--subject` and `--body`. On a branch with a merge queue, follow "Merge queue".
Done when `gh pr view <number> --json state` says `MERGED`.

## Merge queue

A branch has a merge queue when this query returns a value; its `mergeMethod` is the queue's
method:

```sh
gh api graphql -F owner='{owner}' -F name='{repo}' \
  -f query='query($owner:String!,$name:String!){repository(owner:$owner,name:$name){mergeQueue(branch:"<default branch>"){configuration{mergeMethod}}}}' \
  --jq .data.repository.mergeQueue
```

The queue sets the method and the merge commit's message. `gh pr merge <number>` only adds the PR
to the queue, and fails when the repo does not allow auto-merge; then add it with
`gh api -X PUT repos/{owner}/{repo}/pulls/<number>/merge-async`. That is the one fallback endpoint.
Either way the merge lands later: wait until `gh pr view <number> --json state` says `MERGED`
before you move the next PR or delete a branch. Deleting a PR's branch before it merges closes
the PR.

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
`--base <branch below>`. After changing a lower layer, rebase the branches above onto it and push
with `git push --force-with-lease`.

## Merge a stack

A stack on GitHub (linked by `gh stack submit` or `gh stack link`) merges only through GitHub's
async merge API: `gh pr merge` and the REST merge endpoint refuse its PRs. Check out the stack's
top branch and run `gh stack merge`. It merges every PR in the stack, all or none, with the
method the repo allows (`--merge` when merge commits are allowed, else `--squash`), and without
a terminal it does not ask. Pass no number: a bare number is read as a stack number first.

```sh
gh stack merge --yes --merge
```

`gh stack merge` takes no commit message, so the repo's commit message settings write it. On a
branch with a merge queue the PRs join the queue. GitHub runs its rules when the merge runs, and
stacked merges cannot bypass them.

Other stacks merge bottom-up, one PR at a time, the top one included. On a branch with a merge
queue, its `mergeMethod` decides: `MERGE` follows step 1, `SQUASH` and `REBASE` follow steps 2
and 4, since both rewrite the lower commits.

1. With merge commits allowed, merge each layer with a merge commit as in "Merge a PR". The PR
   above already holds the lower commits, so once they land its diff shrinks to its own commits
   with no rewrite.
2. Without merge commits, run `git fetch origin` and record the layer's tip
   (`git rev-parse origin/<branch>`), then squash it as in "Merge a PR".
3. Point the next PR at the default branch with `gh pr edit <next> --base <default branch>`.
   Only then delete the merged branch, with `git push origin --delete <branch>`, unless the repo
   deleted it on merge. Move the PR yourself rather than rely on GitHub's retarget; without the
   move, the next PR merges into the old branch.
4. After a squash, the layers above still hold the old lower commits, so their diff shows them
   again. Rebase the rest of the chain at once, then push each rewritten branch with
   `git push --force-with-lease origin <branch>`, after asking the owner. Bring the local layer
   branches up to date first (`git branch -f <branch> origin/<branch>`, from a detached HEAD):

   ```sh
   git fetch origin
   git rebase --update-refs --onto origin/<default branch> <recorded tip> <top branch>
   ```

5. Wait for the next PR's checks (`gh pr checks <next> --watch --required`), then repeat from
   step 1 with it.

Done when `gh pr view <number> --json state` says `MERGED` for each PR.
