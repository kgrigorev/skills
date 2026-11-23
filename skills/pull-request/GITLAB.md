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
  Push the branch (`git push -u origin <branch>`), then
  `glab mr create --assignee @me --title "<title>" --description-file - --yes` with the body on
  stdin. Add `--draft` for a draft (`--wip` creates a ready MR). It prints the MR's URL.
- **Edit:** `glab mr update <iid> --title "<title>" --description-file -`. On a draft, add
  `--draft`: a new title alone makes the MR ready. An empty description leaves the old one in
  place.
- **MRs targeting a branch:** `glab mr list --target-branch <branch>`.

## Merge settings

`glab api projects/:id` holds them:

- `merge_method`: `merge` (a merge commit), `rebase_merge` (a merge commit, once the branch holds
  its target) or `ff` (fast-forward, no merge commit).
- `squash_option`: `never`, `default_off`, `default_on` or `always`.
- `merge_trains_enabled`: `true` means a merge train. A missing field means none.
- `squash_commit_template` and `merge_commit_template`: a value set there is the project's own
  message. With `squash_commit_template` set, leave out `--squash-message`; with
  `merge_commit_template` set, leave out `-m`.

An MR is ready to merge when `glab mr view <iid> -F json --jq .detailed_merge_status` says
`mergeable`. `unchecked`, `checking`, `preparing` and `approvals_syncing` mean GitLab is still
working it out: poll again, and print the status when it changes. Approvals are required only
when the status is `not_approved`. `ci_still_running` means only the pipeline is left, and
`glab mr merge` arms auto-merge for it. `need_rebase` means the branch lacks its target's latest
commits: under `rebase_merge` (or `ff` when squashing), `git merge --no-edit origin/<target>` and
push clears it without a force-push, since GitLab checks only that the branch holds its target;
under `ff` without squashing (or when the owner wants a linear history and no MR is stacked on
this one), a merge breaks linear history, so ask the owner and run `glab mr rebase <iid>` on their
OK. Any other value (`ci_must_pass`, `not_approved`, `draft_status`, ...) names what blocks it.

## Merge an MR

GitLab's own squash message is the title only, so pass the title and body yourself, along with
`--sha` so concurrent pushes cannot merge unreviewed commits (and groups that require a SHA on
the merge API accept the call). A PR that was never stacked squashes when `squash_option` is not
`never`:

```sh
msg=$(glab mr view <iid> -F json --jq 'if (.description // "") == "" then .title else "\(.title)\n\n\(.description)" end')
glab mr merge <iid> --squash --yes --sha "$(glab mr view <iid> -F json --jq .sha)" \
  --squash-message "$msg"
```

For a merge commit, drop `--squash` and pass `"$msg"` with `-m`; it replaces the whole merge
commit message. Leaving out `--squash` does not stop a squash: when
`glab mr view <iid> -F json --jq .squash_on_merge` is `true`, the merge squashes, so use the
squash form. Under `ff` without a squash there is no merge commit; leave out `-m`.

When `detailed_merge_status` is `ci_must_pass` (or `merge_trains_enabled` is `true` and
`glab mr view <iid> -F json --jq .head_pipeline` is `null`), start a pipeline first:
`glab ci run --mr --branch <source branch>` for merge-request pipelines, or
`glab ci run --branch <source branch>` when the repo uses branch pipelines (`--mr` returns 400
there).

`glab mr merge` merges at once when the MR is `mergeable` (without a merge train). Once the MR
has a pipeline, `glab mr merge` arms auto-merge, or adds or schedules it on the merge train when
`merge_trains_enabled` is `true`, keeping your message and `--remove-source-branch`. Only if
`glab mr merge` refuses on a merge train, fall back to
`glab api -X POST projects/:id/merge_trains/merge_requests/<iid> -F auto_merge=true` (adding
`-F squash=true` when squashing; the train endpoint takes no message or `--remove-source-branch`,
so set branch removal on the MR first).

Poll `glab mr view <iid> -F json --jq .state` until it says `merged`. When it stays `opened` and
`.merge_when_pipeline_succeeds` is `false`, auto-merge was cancelled: stop and report
`detailed_merge_status` to the owner. Deleting an MR's source branch before it merges closes the
MR.

## Build a stack

Build the stack by hand. Cut each branch from the one below, check
`glab mr list --source-branch <branch>`, push `<branch>` (`git push -u origin <branch>`), and open
its MR against `<branch below>`:

```sh
glab mr create --source-branch <branch> --target-branch <branch below> --remove-source-branch \
  --assignee @me --title "<title>" --description-file - --yes
```

Add `--squash-before-merge` when the stack will squash and `squash_option` is `default_off`.
`--remove-source-branch` makes the merge delete the branch, which is what moves the MR above it
to the next target. To change a target later: `glab mr update <iid> --target-branch <branch>`.
After changing a lower layer, merge it into each branch above as in STACKS.md "Build a stack".

## Merge a stack

GitLab has no one-step stack merge. Merge one layer at a time, bottom-up, the top one included,
and keep auto-merge on a single layer at a time: a change of target cancels it. Choose one mode
for the whole stack from the repo's rules and "Merge settings": either every layer squashes
(when `squash_option` is `always`, or when repo rules or `squash_on_merge` call for squashing and
`squash_option` is not `never`), or none does (`merge` and `rebase_merge` take merge commits;
under `ff` without squashing, ask the owner before rebasing the chain, since merging breaks linear
history); an unsquashed layer above a squashed `-s ours` merge would land the lower layer's raw
commits twice.

Before landing the bottom MR, run `git fetch origin` and check that every branch in the stack
holds the tip of the one below it (`git merge-base --is-ancestor origin/<lower> origin/<upper>`);
merge any missing commits upward and push first.

1. Run `git fetch origin` and poll the bottom MR's `detailed_merge_status` past transitional
   states until it is `mergeable` or `ci_still_running` (starting a pipeline as in "Merge an MR"
   if `ci_must_pass` or a train lacks one). When the stack squashes, record its branch's tip:
   `git rev-parse origin/<branch>`.
2. Merge it as in "Merge an MR", adding `--remove-source-branch` to `glab mr merge` (on the
   `merge_trains` fallback, ensure `.force_remove_source_branch` is `true` on the MR first;
   `glab mr update <iid> --remove-source-branch` toggles it when `false`), and poll until it is
   `merged`.
3. Poll `glab mr view <next> -F json --jq .target_branch` for up to a minute, until it names the
   merged MR's target. When it still names the old branch (the branch was protected, or you may
   not delete it), move it yourself: `glab mr update <next> --target-branch <that target>`.
4. Run `git fetch origin`, check out `<next branch>` at `origin/<next branch>`, bring it up to
   date with the first case that applies, and push (each case is a merge, so no force-push):
   - **When the stack squashes:** if `git rev-parse origin/<target>^{tree} <recorded tip>^{tree}`
     prints one value twice, run `git merge -s ours --no-edit origin/<target>`. Otherwise read the
     landed commit (`glab mr view <merged> -F json --jq '(.merge_commit_sha | select(. != null and . != "")) // .squash_commit_sha'`):
     if its `^{tree}` equals `<recorded tip>^{tree}` (`<target>` moved after the squash), run
     `git merge -s ours --no-edit <landed sha>` then `git merge --no-edit origin/<target>`, and
     merge upward; else (`<target>` moved before the squash) run
     `git merge --no-edit origin/<target>`, resolve, and merge upward.
   - **When `! git merge-base --is-ancestor origin/<target> origin/<next branch>`** (under
     `rebase_merge`, or after `<target>` moved under `merge`): run
     `git merge --no-edit origin/<target>` (and merge upward if `<target>` gained outside
     commits).
   - **Otherwise:** nothing to push; its diff shrinks to its own commits on its own.
5. When step 4 pushed nothing, an automatic retarget left the MR with no pipeline; if CI is
   configured and `.head_pipeline` is `null`, start one as in "Merge an MR".
6. Repeat from step 1 with the next MR.

Done when `glab mr view <iid> -F json --jq .state` says `merged` for each MR.
