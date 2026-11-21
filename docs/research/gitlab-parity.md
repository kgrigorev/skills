# GitLab support for the `pull-request` skill: reference for the author

Researched 2026-11-21. Adopted from it: stacks on GitLab are built by hand (`glab stack` is
experimental, create-only and cannot merge a stack), merge requests merge bottom-up with the source
branch deleted so GitLab retargets the next one, the agent writes the merge commit message itself,
and MR dependencies are left out.

Scope: `skills/pull-request/SKILL.md` and `STACKS.md`, both read line by line. The CLI facts are for glab v1.131.0 (2026-11-17, main `0dd7574`) and the server facts for gitlab-org/gitlab master `679228bd`. glab is not installed locally (`command -v glab` exits 1), so every glab fact comes from docs and source, not from `--help` output. Tiers are written F/P/U (Free/Premium/Ultimate). "Source-only" means the fact was read from code and is not stated in the docs.

Minimum glab versions for what follows: `glab stack` needs v1.42.0, `--jq` needs v1.100.0, `--description-file` needs v1.115.0 and `--template <path>` needs v1.124.0 ([mr-create], [stack-idx]; versions from `git tag --contains <commit> --sort=v:refname | head -1` in the glab repo).

## 1. Mechanism map

### SKILL.md

| Line | GitHub | GitLab equivalent | Caveats / tier | Source |
|---|---|---|---|---|
| 3, 6 | "GitHub pull request" | Merge request (MR), referenced as `!<iid>` | Terminology only. | [deps] |
| 8 | "A squash merge makes the title and body the commit" | The default squash template is `%{title}` only, so the body is dropped. To keep the body, set the message yourself: `glab mr merge <iid> --squash --squash-message "<title>\n\n<body>"`. | F/P/U. `--squash-message` is rejected without `--squash`. The project can set `squash_commit_template` (max 500 chars). | [commit-tpl], [mr-merge-doc], [mr-merge-src] |
| 13 | `git diff --stat origin/main...HEAD` | `git diff --stat origin/<target>...HEAD`. Get the target with `glab mr view <iid> -F json --jq .target_branch` or `glab repo view -F json --jq .default_branch`. For an existing MR you can also run `glab mr diff <iid> --raw \| git apply --stat`. | `--jq` needs `-F json` and glab v1.100.0. | [mr-view], [mr-diff], [jq-src] |
| 14 | Split into a stack (STACKS.md) | Same idea; see the STACKS.md table. | | |
| 17 | `.github/pull_request_template.md`, `.github/PULL_REQUEST_TEMPLATE/` | `.gitlab/merge_request_templates/*.md`. `Default.md` (case-insensitive) is the default. There is no single-file location. | The `.md` file method works on F/P/U. A default set in project settings, group-level templates, and instance templates (Self-Managed/Dedicated only) are P/U. Precedence: project-settings template, then the group's `Default.md`, then the project's `Default.md`. The settings template is exposed as `merge_requests_template` on `GET /projects/:id` (P/U). The UI only offers templates that are on the default branch. | [desc-tpl], [projects-api] |
| 17 | (agent fills the template itself) | Read the file, fill it, and pipe the result to `--description-file -`. Do not use `--template`, because it cannot be combined with `--description`, `--description-file`, `--fill` or `--related-issue`. | **The server does not apply `Default.md` or the settings template to MRs created through the API or glab.** Only `BuildService` (the web form) applies them (source-only, not live-tested). `%{...}` variables are not expanded, so fill them yourself. Templates may contain quick actions, which do run. `glab --template` reads the local working tree, not the default branch. A remote list is available at `glab api projects/:fullpath/templates/merge_requests`. | [desc-tpl], [build-svc], [create-svc], [proj-tpl-api], [glab-api] |
| 30 | Title convention: `AGENTS.md`, a CI title check, `git log` | (a) Native "Title pattern": an RE2 regex in Settings > Merge requests, exposed as `merge_request_title_regex`. A non-matching MR cannot merge (`detailed_merge_status` = `title_regex`). (b) A CI job that reads `CI_MERGE_REQUEST_TITLE`: grep `.gitlab-ci.yml` and its includes. (c) `mr_default_title_template` on `GET /projects/:id` hints at the house style. (d) "Require an associated issue from Jira" makes a Jira key in the title or description mandatory. | (a) P/U. Introduced in 17.11 behind a flag, GA in 18.10. From 19.5 the draft prefix is stripped before matching. (b) Works in MR pipelines only. (c) F/P/U. Beta in 18.11, GA in 19.0. glab-created MRs never get it. (d) Ultimate, `jira_association_missing`. | [title-val], [ci-vars], [title-tpl], [jira], [projects-api] |
| 42 | `gh pr create --assignee @me --title "<t>" --body-file -` | `glab mr create --assignee @me --title "<t>" --description-file - --yes` (push the branch first, or add `--push`) | `@me` resolves to the current user. Without `--title` or `--fill`, a non-interactive run fails. `--description -` opens an editor; use `--description-file -`. In a non-TTY run, stdout is the MR URL, except with `--push`, which adds git's output. glab does not check for an existing open MR on the branch, so check first with `glab mr list --source-branch <b>`. | [mr-create], [user-src], [mr-create-src] |
| 42 | `--draft` (used implicitly via gh stack) | `glab mr create --draft`. **Never `--wip`.** | `--wip` prepends `WIP:`, which the server no longer treats as a draft, so the MR is created ready. glab's help text for `--wip` is wrong. | [drafts], [mr-create-src], [draft-regex] |
| 43 | Report the URL | The create output on stdout is `mr.WebURL`, or use `glab mr view <iid> -F json --jq .web_url`. | | [mr-create-src] |
| 53 | `gh pr edit <n> --title "<t>" --body-file -` | `glab mr update <iid> --title "<t>" --description-file -` | Use the IID or URL, not a branch name: selecting by branch searches MRs in any state and fails when there are several. **An empty description is silently ignored**, so the old one stays. **`--title` on a draft drops `Draft:` and marks the MR ready** unless you also pass `--draft`. `--yes` matters only with `--fill`. `--squash-before-merge` and `--remove-source-branch` toggle the current value; they do not set it. | [mr-update], [mr-update-src], [mrutils] |
| 57 | Merge when checks are green and reviews are in | Read `detailed_merge_status`: only `mergeable` means ready. Other values include `draft_status`, `ci_must_pass`, `not_approved`, `merge_request_blocked`, `title_regex`, `jira_association_missing`, … | `merge_status` was deprecated in 15.6. | [mr-api-status] |
| 59 | `gh repo view --json mergeCommitAllowed,squashMergeAllowed,rebaseMergeAllowed` | `glab api projects/:id` and read `merge_method` (exactly one of `merge`, `rebase_merge`, `ff`) and `squash_option` (`never`, `default_off`, `default_on`, `always`). For a given MR, `squash_on_merge` is the effective squash decision. | F/P/U. Requires authentication, but no particular role: an unauthenticated request gets an entity without these fields. | [projects-api], [projects-rb], [project-entity], [mr-api] |
| 61 | Squash a PR that was never stacked | `glab mr merge <iid> --squash --squash-message "<msg>" --yes`. This works only if `squash_option` is not `never`; `always` forces a squash. | Sending `squash=false` at merge time does not clear the MR's squash flag. | [squash-opt], [merge-api-rb] |
| 62 | Stacked PR: its base is another branch, or another open PR targets its branch | Same test. GitLab 19.1+ shows these chains as "Stacked merge requests" when one author owns them all (19.2+) and there are at most 20 MRs. | F/P/U. | [stacked-mrs] |
| 63 | "When GitHub refuses a merge, report its message" | glab refuses on its own before calling the API: drafts, closed or merged MRs, conflicts, `ci_must_pass`, and users who cannot merge. The API then returns 400 (SHA required), 401, 405, 409 (SHA mismatch) or 422 ("Branch cannot be merged"). Report the message. | glab's retry on 406 never fires against current GitLab. | [mr-merge-src], [mrutils], [merge-api] |

### STACKS.md

| Line | GitHub | GitLab equivalent | Caveats / tier | Source |
|---|---|---|---|---|
| 11-13 | Ask the owner before a force-push (`gh stack submit`, `git push --force-with-lease`) | The same rule covers `glab stack sync` after `amend`, `reorder` or `--update-base`. In those cases it runs `git rebase --fork-point --update-refs` and then `git push origin --force-with-lease` with **every** stack branch. To show the owner first, run `glab stack sync --skip-push` (v1.121.0), then a plain `sync`. | The remote is hard-coded to `origin`. | [stack-sync-src], [git-src] |
| 15 | `gh extension list` shows gh-stack | `glab stack` is built in (alias `glab stacks`). Detect it with `glab stack --help`, or with `glab version` ≥ 1.42.0. | **EXPERIMENT** ("not ready for production use… might be unstable or removed at any time"). F/P/U. | [stack-idx], [stacked-diffs] |
| 15-16 | GitHub "shows the PRs as one stack and merges them in one step" | It shows them as one stack (19.1+, for manual and glab stacks alike). **There is no one-step merge.** | | [stacked-mrs] |
| 16 | `gh stack add` for each layer | `glab stack create <name>` once, with the checked-out branch as the base; push the base first. Then one `glab stack save -m "<subject>" [files\|.\|-a]` per layer. `glab stack amend` folds changes into the current diff. | Each layer is one commit on its own branch, so do not add plain `git commit`s ("your Git branch is ahead…"). Run `glab stack last` before `save`, because saving from a middle diff still appends the new diff at the end. Without `-m`, an editor opens. Branch names are generated (`<prefix>-<title>-<8hex>`) and cannot be chosen. | [stack-save], [stack-save-src], [stackutils] |
| 16 | `gh stack submit` | `glab stack sync`. It pushes, creates the missing MRs (each targeting the previous diff's branch, with `RemoveSourceBranch=true` and you as assignee), and drops diffs whose MRs merged. | It **never updates** an existing MR's title, description or target. | [stack-sync], [stack-sync-src] |
| 18 | `gh stack init <b1> <b2> <b3>` | No equivalent. The closest is `glab stack infer [--all] <branch>..HEAD`, which cherry-picks each commit onto a **new** glab-named branch, and sync then opens new MRs for them. | v1.100.0. Works without a TTY with `--all` from v1.129.0. It does not adopt existing branches or MRs. | [stack-infer], [stack-infer-src] |
| 18-19 | `gh stack view` shows "Needs rebase" | No equivalent. `glab stack list` shows only branches and descriptions. | | [stack-list] |
| 19 | `gh stack rebase`, then `gh stack submit` | After an amend: `glab stack sync`. After a lower MR merges: `glab stack sync --update-base` (v1.89.0), which force-pushes. | Whether `--fork-point` drops a squash-merged lower commit is unverified. | [stack-sync] |
| 20-21 | Manual stack: `--base <branch below>` | `glab mr create -s <b> -b <branch below> --remove-source-branch --title … --description-file - --yes`. Change the target later with `glab mr update <iid> --target-branch <b>`. | Set `--remove-source-branch` at create time, because it makes the merge delete the branch, and that deletion is what triggers the retarget. On update the flag toggles, so check the current value first. | [mr-create], [mr-update] |
| 21-22 | Rebase the branches above, push `--force-with-lease` | Same (plain git). | | |
| 24-26 | `gh stack submit` without a TTY opens drafts with generated titles; `--open` makes them ready | `glab stack sync` has no `--draft` or `--open` flag and creates MRs **ready**. The title is the commit subject (cut to 249 chars + `...` past 252), and the description is the commit body (with `--template`, the template text comes first). Fix each with `glab mr update <iid> --title … --description-file -`. Make one a draft with `glab mr update <iid> --draft`. | | [stack-sync-src] |
| 28-29 | `Depends on #<number>.` (text only) | Text convention: `Depends on !<iid>.` Optionally, enforced **MR dependencies**: `glab api -X POST projects/:id/merge_requests/<iid>/blocks -f blocking_merge_request_iid=<n>`. The dependent MR cannot merge (`merge_request_blocked`) until the blocker merges. | Dependencies are P/U, enforced in the dependent MR's project. Up to 10 blockers per MR. Closed blockers still block. glab has no subcommand for them, and `:iid` is not a glab placeholder. | [deps], [mr-api], [glab-api] |
| 33-34 | Linked stacks merge only through the async API; `gh pr merge` refuses them | No such restriction was found: the stack is inferred from target branches, and `glab mr merge` works on each MR. | | [stacked-mrs] |
| 35-41 | `gh stack merge <n> --yes --merge` (all or none) | **None.** Merge bottom-up, one MR at a time (section 2). | | [stack-idx], [stacked-mrs] |
| 43-44 | Merge queue sets the method; rules cannot be bypassed | Merge trains (P/U); see lines 64-68. | | [trains] |
| 46-47 | Bottom-up; one merge commit per layer when allowed | The same applies when `merge_method` = `merge`. Under `rebase_merge` or `ff`, the next MR is behind `main` and must be rebased first: `glab mr rebase <iid>`, or automatic rebase before merge (GA 19.2, F/P/U, Maintainer to enable). | | [methods], [rebase-doc] |
| 48-49 | The next PR shrinks with no rewrite | True under `merge`, once the MR has a fresh pipeline (section 2). | | [update-svc] |
| 52 | `gh pr view … -q .body \| gh pr merge --merge --body-file -` | `glab mr merge <iid> -m "<message>" --yes`. `-m` replaces the **whole** merge commit message, so compose it yourself, for example with the body from `glab mr view <iid> -F json --jq .description`. | There is no `--body-file`. A custom message is kept through a deferred auto-merge or train (source-only). | [mr-merge-doc], [from-src-branch], [auto-base] |
| 55 | `gh pr edit <next> --base main`, then delete the merged branch | **Reversed.** Merge with the source branch deleted as part of the merge (`-d`, or the MR's own setting). GitLab then retargets the next MR itself. If you delete the branch as a separate step, first retarget manually with `glab mr update <next> --target-branch main`. | See section 2 for limits (at most 4 MRs, same project only, needs permission to delete the branch). | [mrs-retarget], [retarget-svc] |
| 56 | "Deleting a branch closes the PRs based on it" | **False on GitLab.** MRs that *target* a deleted branch stay open against a missing target until they are retargeted. | | [refresh-svc] |
| 57 | Without the move, the next PR merges into the old branch | It stays open against the missing branch. GitLab also refuses to merge it while the target is queued for deletion: "Please wait for the branch to be retargeted." | | [merge-svc] |
| 59-62 | Squash each layer; `git rebase --onto origin/main <old lower> <branch>` | Same git fix: record the lower branch's tip SHA before merging it with `-d`. For glab stacks, use `glab stack sync --update-base`. | **Unverifiable**: no GitLab document covers squash inside a stack. | [squash-doc], [stack-sync] |
| 64-65 | `gh api …/rules/branches/main` lists `merge_queue` | `glab api projects/:id` → `merge_trains_enabled`. | On Free the field is **absent**, not `false`. Treat a missing field as "no train". | [ee-project-entity] |
| 65-66 | The queue sets the method; follow `merge_method` | The project `merge_method` still applies. Trains also need pipelines. | | [trains] |
| 66-68 | `gh pr merge` only enqueues; it fails without auto-merge; fall back to `PUT …/merge-async` | `glab mr merge <iid> --auto-merge --yes`, or `glab api -X POST projects/:id/merge_trains/merge_requests/<iid> -f auto_merge=true` (returns 201 when added, 202 when scheduled). | glab sends `auto_merge` only when the MR has a pipeline. Without one it merges directly, which bypasses the train, or returns 405 where trains are enforced (19.3 GA). The trains API needs the Developer role or higher. | [trains-api], [mr-merge-src], [trains] |
| 69 | Wait for `MERGED` | `glab mr view <iid> -F json --jq .state` == `merged`. Train position is at `GET projects/:id/merge_trains/merge_requests/<iid>`. | States are `opened`, `closed`, `merged` and `locked` (transitional). | [mr-api], [trains-api] |
| 69-70 | Deleting a PR's branch before it merges closes the PR | **Same.** `RefreshService` closes open MRs whose *source* branch is gone. | | [refresh-svc] |
| 72-74 | Done when every PR is `MERGED`; report the refusal; no other endpoint | Same, with the status codes above. | | [merge-api] |
| 78-84 | `git diff $(git merge-base origin/main <top>)..<top>` | Same (plain git), with `origin/<default branch>`. | | |

## 2. Behaviour differences that change the procedure

- **Retarget happens on merge, not on delete.** Retargeting runs only when the source branch is deleted *as part of the merge* (`DeleteSourceBranchWorker` → `RetargetChainService`). Limits: at most 4 open MRs, the merged MR must be in the same project, and only MRs the merging user can update are moved. Retargeted MRs go to the merged MR's **own target**, not always the default branch. The deletion, and so the retarget, needs `should_remove_source_branch` or the MR's `force_remove_source_branch`, *and* the merging user must be allowed to remove the branch (a protected branch or a missing role means no retarget). Deleting the branch later through the UI or `git push --delete` retargets nothing; issue #321559 is still open. The stacked-MR page says "merge, then delete its source branch", which conflicts with the MR page and the source. Follow the source. ([mrs-retarget], [retarget-svc], [delete-worker], [merge-svc], [issue-321559])
- **Upper MRs are not closed** when their target branch disappears. Only MRs whose *source* branch is gone are closed ([refresh-svc]).
- **A retarget costs the next layer its pipeline and auto-merge** (source-only, [update-svc]). Any target change cancels auto-merge ("the target branch was changed."). An automatic retarget also sets `head_pipeline_id = nil` and starts no pipeline, so under "Pipelines must succeed" the MR stays blocked. Start one with `glab ci run --mr`, `POST /projects/:id/merge_requests/:iid/pipelines`, a push, or a rebase without `--skip-ci` ([ci-run], [mr-api]). A manual `glab mr update --target-branch` does start pipelines. On EE, approvals may be reset when `reset_approvals?` holds (inferred). **Therefore: do not arm auto-merge on several layers at once.**
- **Auto-merge is also cancelled** when the target branch advances under `rebase_merge` or `ff`, unless automatic rebase is on. Keeping it through that is behind the flag `retain_auto_merge_with_automatic_rebase` (19.3, off by default) ([auto-merge]).
- **Wait for the retarget before merging the next MR.** Merging while the target branch is queued for deletion fails with "The target branch is scheduled for deletion. Please wait for the branch to be retargeted." ([merge-svc])
- **Per-layer stack merge procedure:** check the next MR's `detailed_merge_status`; merge the current MR with `-d`; poll until its state is `merged`; poll until the next MR's `target_branch` changes; under `rebase_merge` or `ff`, rebase the next MR; make sure it has a fresh pipeline; repeat.
- **`glab mr merge` defaults to `--auto-merge=true`.** If the MR is already mergeable and has no pipeline in progress, the API merges it **immediately**; otherwise it arms auto-merge and the MR merges later. Always poll for `merged`. Use `--auto-merge=false` to force an immediate attempt. Cancel with `POST …/cancel_auto_merge` (19.5) ([merge-api-rb], [mwcp-svc], [mr-api]).
- **One merge method per project.** `merge` always creates a merge commit, even when squashing. `rebase_merge` creates a merge commit but merges only when a fast-forward is possible. `ff` creates no merge commit. Squash is a separate option that works with all three ([methods], [squash-doc]).
- **SHA guard and rebase conflict.** `glab mr merge --sha` and `--rebase` cannot be combined. Where "Require a commit SHA on the merge requests API" is on (19.2+, a group or instance setting), `glab mr merge --rebase` therefore always returns 400. Instead run `glab mr rebase <iid>`, wait, read the new `.sha`, then `glab mr merge --sha <sha>` ([group-sha], [mr-merge-src]).
- **Draft is a title prefix.** `[Draft]`, `Draft:` or `(Draft)`, matched case-insensitively. Retitling without `--draft` makes the MR ready. Use `--draft` and `--ready`, never `--wip` ([drafts], [draft-regex]).
- **glab stack is commit-per-branch and create-only.** Edits to an MR's title or description after sync are manual (`glab mr update`), and there is no draft mode.
- **Squash default drops the body.** Pass the message explicitly at merge if the skill keeps "title and body become the commit" ([commit-tpl]).

## 3. Gaps and unsettled points

No GitLab equivalent:
- An atomic, all-or-none stack merge (`gh stack merge`).
- `gh stack view` "Needs rebase".
- `gh stack init`, which adopts existing branches and PRs. `infer` makes new ones.
- Choosing branch names per layer, and `gh stack link`.
- A draft or `--open` mode in `glab stack sync`.
- A `--body-file` for merge messages: the message goes in `-m` or `--squash-message` as a string.
- Merge dependencies on Free: on that tier, `Depends on !<iid>.` stays plain text.

Unsettled or unverified:
- Creating a duplicate MR for a branch that already has an open one: glab has no pre-check and the API docs list no 409. Check before creating.
- Whether `git rebase --fork-point` in `glab stack sync --update-base` cleanly drops a squash-merged lower commit.
- Squash inside a stack in general: no GitLab document covers it.
- That templates are not applied to API creates, that custom messages survive auto-merge and trains, and the retarget's pipeline, auto-merge and approval effects: all read from source, not documented, not live-tested.
- A verified glab flag to list MRs by target branch (to find "another open MR targets its branch"). Only `glab mr list --source-branch` was confirmed.
- The `/blocks` dependency API has no version history in the REST docs.
- Whether the stacked-MR UI (19.1) sits behind a feature flag: the docs history names none, but the full flag list was not searched.
- When WIP support was removed: the about.gitlab.com 14.0 blog conflicts with gitlab-org/gitlab!79693, merged in milestone 14.8. Either way, `WIP:` is not a draft today.

Refuted or corrected claims (do not use):
- `--wip` is a draft alias. Refuted: it prepends `WIP:`, which the server ignores.
- glab's default target branch comes from target-branch rules on every tier. Corrected: those rules are P/U; on Free the default is always the project default branch.
- `glab stack sync` creates *or updates* MRs. Refuted: it only creates them.
- glab's 406 retry covers a transient error after a rebase. Refuted: the endpoint never returns 406.
- Auto-merge by default always defers the merge. Refuted: it merges at once when the MR is already mergeable.
- The rebase rate limit is on by default. Refuted: it sits behind a flag introduced in 19.6 that is off by default.
- `merge_trains_enabled` is `false` on Free. Refuted: the field is absent.
- Retargeted MRs always go to the default branch. Refuted: they go to the merged MR's own target.
- The "ahead" error in `glab stack sync` is about the recorded stack state. Corrected: it compares the branch with its remote.
- `mr_default_title_template` is not exposed in the API. Refuted: it is on `GET /projects/:id`.

## 4. Platform detection

1. Run `git remote get-url origin` (in a fork, check `upstream` too, because glab prefers `upstream` > `gitlab` > `origin` as the base repo). A host of `github.com` means GitHub (gh); `gitlab.com` means GitLab (glab) ([remote-src]).
2. For any other host, `glab auth status --hostname <host>` exits 0 when glab is configured and authenticated for it. It fails with "<host> has not been authenticated with glab" when it is not, so then try `gh auth status --hostname <host>`. Do not probe `GET /api/v4/version` unauthenticated: the docs do not promise it works ([auth-status], [metadata]).
3. Honour the overrides: `GITLAB_HOST`, `GL_HOST` and `GITLAB_URI` always win; `GLAB_REMOTE_ALIAS` names the remote; `GITLAB_REPO` applies when no `-R` is given ([config]).
4. Check the tools: `command -v glab`, then `glab version` against the minimums at the top. `glab stack --help` shows whether stacks are available.
5. Read the project capabilities once with `glab api projects/:id`: `merge_method`, `squash_option`, `merge_trains_enabled` (absent means no train, which hints at Free), `only_allow_merge_if_pipeline_succeeds`, `remove_source_branch_after_merge` and `merge_request_title_regex` ([projects-api], [ee-project-entity]).
6. Set `GLAB_NO_PROMPT` (or `NO_PROMPT`) and pass `--yes` so runs without a terminal never block on a prompt ([config]).

[mr-create]: https://docs.gitlab.com/cli/mr/create/
[mr-create-src]: https://gitlab.com/gitlab-org/cli/-/raw/main/internal/commands/mr/create/mr_create.go
[mr-update]: https://docs.gitlab.com/cli/mr/update/
[mr-update-src]: https://gitlab.com/gitlab-org/cli/-/raw/main/internal/commands/mr/update/mr_update.go
[mr-view]: https://docs.gitlab.com/cli/mr/view/
[mr-diff]: https://docs.gitlab.com/cli/mr/diff/
[jq-src]: https://gitlab.com/gitlab-org/cli/-/raw/main/internal/cmdutils/jq_flag.go
[mrutils]: https://gitlab.com/gitlab-org/cli/-/raw/main/internal/commands/mr/mrutils/mrutils.go
[user-src]: https://gitlab.com/gitlab-org/cli/-/raw/main/internal/api/user.go
[mr-merge-doc]: https://gitlab.com/gitlab-org/cli/-/raw/main/docs/source/mr/merge.md
[mr-merge-src]: https://gitlab.com/gitlab-org/cli/-/raw/main/internal/commands/mr/merge/mr_merge.go
[glab-api]: https://gitlab.com/gitlab-org/cli/-/raw/main/docs/source/api/_index.md
[ci-run]: https://gitlab.com/gitlab-org/cli/-/raw/main/docs/source/ci/run.md
[auth-status]: https://docs.gitlab.com/cli/auth/status/
[config]: https://docs.gitlab.com/cli/configuration/
[remote-src]: https://gitlab.com/gitlab-org/cli/-/raw/main/internal/glrepo/remote.go
[git-src]: https://gitlab.com/gitlab-org/cli/-/raw/main/internal/git/git.go
[stack-idx]: https://gitlab.com/gitlab-org/cli/-/raw/main/docs/source/stack/_index.md
[stack-save]: https://gitlab.com/gitlab-org/cli/-/raw/main/docs/source/stack/save.md
[stack-save-src]: https://gitlab.com/gitlab-org/cli/-/raw/main/internal/commands/stack/save/stack_save.go
[stack-sync]: https://gitlab.com/gitlab-org/cli/-/raw/main/docs/source/stack/sync.md
[stack-sync-src]: https://gitlab.com/gitlab-org/cli/-/raw/main/internal/commands/stack/sync/stack_sync.go
[stack-infer]: https://gitlab.com/gitlab-org/cli/-/raw/main/docs/source/stack/infer.md
[stack-infer-src]: https://gitlab.com/gitlab-org/cli/-/raw/main/internal/commands/stack/infer/stack_infer.go
[stack-list]: https://gitlab.com/gitlab-org/cli/-/raw/main/docs/source/stack/list.md
[stackutils]: https://gitlab.com/gitlab-org/cli/-/raw/main/internal/commands/stack/stackutils/stackutils.go
[stacked-diffs]: https://docs.gitlab.com/user/project/merge_requests/stacked_diffs/
[stacked-mrs]: https://docs.gitlab.com/user/project/merge_requests/reviews/stacked_merge_requests/
[drafts]: https://docs.gitlab.com/user/project/merge_requests/drafts/
[draft-regex]: https://gitlab.com/gitlab-org/gitlab/-/raw/master/lib/gitlab/regex/merge_requests.rb
[desc-tpl]: https://docs.gitlab.com/user/project/description_templates/
[proj-tpl-api]: https://docs.gitlab.com/api/project_templates/
[build-svc]: https://gitlab.com/gitlab-org/gitlab/-/raw/master/app/services/merge_requests/build_service.rb
[create-svc]: https://gitlab.com/gitlab-org/gitlab/-/raw/master/app/services/merge_requests/create_service.rb
[title-val]: https://docs.gitlab.com/user/project/merge_requests/title_validation/
[title-tpl]: https://docs.gitlab.com/user/project/merge_requests/title_templates/
[ci-vars]: https://docs.gitlab.com/ci/variables/predefined_variables/
[jira]: https://docs.gitlab.com/integration/jira/issues/
[commit-tpl]: https://docs.gitlab.com/user/project/merge_requests/commit_templates/
[projects-api]: https://docs.gitlab.com/api/projects/
[projects-rb]: https://gitlab.com/gitlab-org/gitlab/-/raw/master/lib/api/projects.rb
[project-entity]: https://gitlab.com/gitlab-org/gitlab/-/raw/master/lib/api/entities/project.rb
[ee-project-entity]: https://gitlab.com/gitlab-org/gitlab/-/raw/master/ee/lib/ee/api/entities/project.rb
[squash-opt]: https://gitlab.com/gitlab-org/gitlab/-/raw/master/app/models/concerns/projects/squash_option.rb
[mr-api]: https://docs.gitlab.com/api/merge_requests/
[mr-api-status]: https://docs.gitlab.com/api/merge_requests/#merge-status
[merge-api]: https://docs.gitlab.com/api/merge_requests/#merge-a-merge-request
[merge-api-rb]: https://gitlab.com/gitlab-org/gitlab/-/raw/master/lib/api/merge_requests.rb
[mwcp-svc]: https://gitlab.com/gitlab-org/gitlab/-/raw/master/app/services/auto_merge/merge_when_checks_pass_service.rb
[auto-base]: https://gitlab.com/gitlab-org/gitlab/-/raw/master/app/services/auto_merge/base_service.rb
[from-src-branch]: https://gitlab.com/gitlab-org/gitlab/-/raw/master/app/services/merge_requests/merge_strategies/from_source_branch.rb
[auto-merge]: https://docs.gitlab.com/user/project/merge_requests/auto_merge/
[methods]: https://docs.gitlab.com/user/project/merge_requests/methods/
[rebase-doc]: https://docs.gitlab.com/api/merge_requests/#rebase-a-merge-request
[squash-doc]: https://docs.gitlab.com/user/project/merge_requests/squash_and_merge/
[group-sha]: https://docs.gitlab.com/user/group/manage/#require-a-commit-sha-on-the-merge-requests-api
[trains]: https://docs.gitlab.com/ci/pipelines/merge_trains/
[trains-api]: https://docs.gitlab.com/api/merge_trains/
[deps]: https://docs.gitlab.com/user/project/merge_requests/dependencies/
[mrs-retarget]: https://docs.gitlab.com/user/project/merge_requests/#update-merge-requests-when-target-branch-merges
[retarget-svc]: https://gitlab.com/gitlab-org/gitlab/-/raw/master/app/services/merge_requests/retarget_chain_service.rb
[delete-worker]: https://gitlab.com/gitlab-org/gitlab/-/raw/master/app/workers/merge_requests/delete_source_branch_worker.rb
[merge-svc]: https://gitlab.com/gitlab-org/gitlab/-/raw/master/app/services/merge_requests/merge_service.rb
[update-svc]: https://gitlab.com/gitlab-org/gitlab/-/raw/master/app/services/merge_requests/update_service.rb
[refresh-svc]: https://gitlab.com/gitlab-org/gitlab/-/raw/master/app/services/merge_requests/refresh_service.rb
[issue-321559]: https://gitlab.com/api/v4/projects/278964/issues/321559
[metadata]: https://docs.gitlab.com/api/metadata/