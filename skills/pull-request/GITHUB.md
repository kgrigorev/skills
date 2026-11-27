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

## Checks and reviews

Run `gh pr checks <n> --watch --required` and wait for every required check. If a check finishes
in a few seconds with an annotation starting `The job was not started`, it never ran; report it
as blocked, not as a test failure. Get the check-run ID from the last path segment of the check's
`link` (`gh pr checks <n> --json name,link`) and inspect its annotations with
`gh api repos/{owner}/{repo}/check-runs/<id>/annotations`. Done when every required check passes;
report a not-started check as blocked, never as a pass or test failure.

Check the review state with `gh pr view <n> --json reviewDecision`. `REVIEW_REQUIRED` means wait
for approval; `APPROVED` satisfies the review requirement. An empty value means no review is
required. Classic branch protection can require reviews through `required_pull_request_reviews`:

```sh
gh api "repos/{owner}/{repo}/branches/<base>/protection"
```

A `404` whose response says `Branch not protected` means no classic rule applies; a different
`404` or a `403` can mean the token cannot read the settings, so ask the owner. Repository and
organization rulesets can also require reviews; inspect applicable rules with
`gh api repos/{owner}/{repo}/rules/branches/<base>` for a `pull_request` rule and
`required_approving_review_count`; a positive count requires that many approvals. If
`required_pull_request_reviews` is `null`, classic branch protection requires no review, but
rulesets may still do so. Done when `reviewDecision` is not `REVIEW_REQUIRED` and any ruleset
review requirement is satisfied.

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

Read whether GitHub has linked the PRs before choosing a command. A bare number passed to
`gh stack merge` is a stack number first and a pull request number second, so read the stack
number from the bottom PR:

```sh
gh api graphql -F owner='{owner}' -F name='{repo}' -F number=<bottom PR> \
  -f query='query($owner:String!,$name:String!,$number:Int!){repository(owner:$owner,name:$name){pullRequest(number:$number){stack{number}}}}' \
  --jq '.data.repository.pullRequest.stack.number // empty'
```

When that prints a number, merge the whole stack from this clone. Pass the one flag the repo
allows, `--squash`, `--merge`, or `--rebase` (see "Merge settings"). When the repo allows more
than one, use the method its `AGENTS.md` or contributing guide names.

```sh
gh stack merge <stack number> --yes --squash
```

The command carries the stack number, so it runs from the default branch and from a detached
HEAD. `gh stack merge` takes no commit message, so the repo's commit message settings write it.
On a branch with a merge queue the PRs join the queue. GitHub runs its rules when the merge
runs, and a linked stack cannot bypass them.

For a not-started check, follow "Checks and reviews" above.
The local check on the top branch's tree is the evidence.
Required status checks still block `gh stack merge`. When the owner says to merge without CI,
unlink the stack with `gh stack unstack <stack number>` and land it with
`scripts/land-squash-stack --admin-if-unstarted` ("Without merge commits" below). This changes no
branch protection. Only when the repo allows no squash merges or refuses `--admin`, clear the
required checks instead. That is a branch-protection change: name each context you remove, put
the command that restores those contexts in the report to the owner, and leave every other
protection setting as it was.

`scripts/land-squash-stack` stops when the bottom PR is in a linked stack and prints the
`gh stack merge` command; follow it, or see above when the checks never start.

Done when every PR's state is `MERGED` and the default branch's tree equals the top branch's
tree. These two hashes are the same:

```sh
git fetch origin
git rev-parse "origin/<default>^{tree}" "<top>^{tree}"
```

If a required check was removed, the report to the owner names each context and the restore
command.

When the query prints nothing, GitHub has not linked the PRs. Merge that stack from the bottom
up, one PR at a time, the top one included.

**With merge commits allowed**, for each layer:

1. Merge it with a merge commit as in "Merge a PR". The PR above already holds the lower
   commits, so once they land its diff shrinks to its own commits with no rewrite.
2. Point the next PR at the default branch with `gh pr edit <next> --base <default branch>`.
   Only then delete the merged branch, with `git push origin --delete <branch>`, unless the repo
   deleted it on merge or open PRs are based on it. Move the PR yourself rather than rely on
   GitHub's retarget; without the move, the next PR merges into the old branch.
3. Wait for the next PR's checks (`gh pr checks <next> --watch --required`), then repeat with it.

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
the message to GitHub when `squash_merge_commit_message` is `BLANK`. When a check fails, the
stop line includes each failing check run's annotation. When every failing run has annotations
and all of them say the job was not started, it stops and says the checks never started. The local
check on the PR's head is the evidence.

Pass `--admin-if-unstarted` when the checks never started (no Actions minutes left, for example),
the local check passed on each PR's head, and the owner said to merge without CI. The script then
squashes each such PR with `gh pr merge --admin` once two reads of its checks, one poll interval
apart, agree; a check that registers later than that is not seen. It never clears a real failure: a check that ran and failed,
or a failing commit status, still stops it, and so does a required review. The `To continue`
command keeps the flag.

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

For a stack GitHub has not linked, done when `gh pr view <number> --json state` says `MERGED`
for each PR.
