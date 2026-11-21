# GitLab

Commands for [`SKILL.md`](SKILL.md) and [`STACKS.md`](STACKS.md) on GitLab, with the `glab` CLI.
A PR is a merge request (MR), named by its IID (`!<iid>`).

Use glab v1.115.0 or newer (`glab version`); with an older one, ask the owner to upgrade. Set
`GLAB_NO_PROMPT=1` for every command, and pass `--yes` where a command below shows it. Address an
MR by its IID or URL, not by its branch.

## Open and update

- **Default branch:** `glab repo view -F json --jq .default_branch`.
- **Template:** a file in `.gitlab/merge_request_templates/`; `Default.md` is the default. A
  template set in the project's settings is `merge_requests_template` in
  `glab api projects/:id`, and comes first. glab and the API never apply a template, so read it,
  fill it yourself (its `%{...}` variables too) and pass the result as the description. Keep its
  lines that start with `/` as they are: they are quick actions, and they run on create.
- **Title rule:** `merge_request_title_regex` in `glab api projects/:id`, or a CI job in
  `.gitlab-ci.yml` that reads `CI_MERGE_REQUEST_TITLE`.
- **Create:** first check that the branch has no open MR: `glab mr list --source-branch <branch>`.
  Push the branch, then
  `glab mr create --assignee @me --title "<title>" --description-file - --yes` with the body on
  stdin. Add `--draft` for a draft (`--wip` creates a ready MR). It prints the MR's URL.
- **Edit:** `glab mr update <iid> --title "<title>" --description-file -`. On a draft, add
  `--draft`: a new title alone makes the MR ready. An empty description leaves the old one in
  place.
- **MRs targeting a branch:** `glab mr list --target-branch <branch>`.

## Merge settings

`glab api projects/:id` holds them:

- `merge_method`: `merge` (a merge commit), `rebase_merge` (a merge commit, only once the branch
  is rebased) or `ff` (fast-forward, no merge commit).
- `squash_option`: `never`, `default_off`, `default_on` or `always`.
- `merge_trains_enabled`: `true` means a merge train. A missing field means none.
- `squash_commit_template` and `merge_commit_template`: a value set there is the project's own
  message. With `squash_commit_template` set, leave out `--squash-message`; with
  `merge_commit_template` set, leave out `-m`.

An MR is ready to merge when `glab mr view <iid> -F json --jq .detailed_merge_status` says
`mergeable`. `unchecked`, `checking`, `preparing` and `approvals_syncing` mean GitLab is still
working it out: poll again. `ci_still_running` means only the pipeline is left, and
`glab mr merge` arms auto-merge for it. `need_rebase` means rebase it (`glab mr rebase <iid>`, or
the chain in "Merge a stack" step 4), wait for the new pipeline, and check again. Any other value
(`ci_must_pass`, `not_approved`, `draft_status`, ...) names what blocks it.

## Merge an MR

GitLab's own squash message is the title only, so pass the title and body yourself. A PR that was
never stacked squashes when `squash_option` is not `never`:

```sh
glab mr merge <iid> --squash --yes \
  --squash-message "$(glab mr view <iid> -F json --jq '.title + "\n\n" + .description')"
```

For a merge commit, drop `--squash` and pass the same message with `-m`; it replaces the whole
merge commit message. Leaving out `--squash` does not stop a squash: when
`glab mr view <iid> -F json --jq .squash_on_merge` is `true`, the merge squashes, so use the
squash form. Under `ff` without a squash there is no merge commit; leave out `-m`.

`glab mr merge` merges at once when the MR is `mergeable`. While a pipeline runs, it arms
auto-merge, and GitLab merges once every check passes. With no pipeline it only tries an
immediate merge, so start one first: `glab ci run --mr --branch <source branch>`.

With `merge_trains_enabled`, add the MR to the train instead, once it has a pipeline (add
`-f squash=true` when it squashes). The train takes no message, so GitLab writes it:

```sh
glab api -X POST projects/:id/merge_trains/merge_requests/<iid> -f auto_merge=true
```

Either way, poll `glab mr view <iid> -F json --jq .state` until it says `merged`. When it stays
`opened` and `.merge_when_pipeline_succeeds` is `false`, auto-merge was cancelled: stop and report
`detailed_merge_status` to the owner.

## Build a stack

Build the stack by hand. Cut each branch from the one below and open its MR against that branch:

```sh
glab mr create --source-branch <branch> --target-branch <branch below> --remove-source-branch \
  --assignee @me --title "<title>" --description-file - --yes
```

`--remove-source-branch` makes the merge delete the branch, which is what moves the MR above it
to the next target. To change a target later: `glab mr update <iid> --target-branch <branch>`.
After changing a lower layer, rebase the branches above onto it and push with
`git push --force-with-lease`.

## Merge a stack

GitLab has no one-step stack merge. Merge one layer at a time, bottom-up, the top one included,
and keep auto-merge on a single layer at a time: a change of target cancels it. A layer squashes
when its `squash_on_merge` is `true`; otherwise it takes a merge commit under `merge` and
`rebase_merge`, and fast-forwards under `ff`.

1. Run `git fetch origin` and check that the bottom MR is `mergeable`, or that only its pipeline
   is left (`ci_still_running`). When it will squash, record its branch's tip first:
   `git rev-parse origin/<branch>`.
2. Merge it as in "Merge an MR", with `--remove-source-branch`, and poll until it is `merged`.
3. Poll `glab mr view <next> -F json --jq .target_branch` for up to a minute, until it names the
   merged MR's target. When it still names the old branch (the branch was protected, or you may
   not delete it), move it yourself: `glab mr update <next> --target-branch <that target>`.
4. Run `git fetch origin`, then bring the rest of the chain up to date with the first case that
   applies. A rebase takes the whole chain at once, so the layers above move with the next one:
   bring the local layer branches up to date first (`git branch -f <branch> origin/<branch>`,
   from a detached HEAD), and afterwards push each rewritten branch with
   `git push --force-with-lease origin <branch>`, after asking the owner.
   - After a squash, under any `merge_method`, the layers above still hold the old lower commits:
     `git rebase --update-refs --onto origin/<target> <recorded tip> <top branch>`.
   - Under `rebase_merge` or `ff`: `git rebase --update-refs origin/<target> <top branch>`. For
     the top layer alone, `glab mr rebase <iid>` does the same on the server.
   - Under `merge`: nothing to do; its diff shrinks to its own commits on its own.
5. A retarget leaves the MR without a pipeline. Start one when none runs:
   `glab ci run --mr --branch <next MR's source branch>`.
6. Repeat from step 1 with the next MR.

Done when `glab mr view <iid> -F json --jq .state` says `merged` for each MR. Deleting an MR's
source branch before it merges closes the MR.
