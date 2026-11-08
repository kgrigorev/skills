---
name: archive-project
description: Move a finished Git repo into your archive repo, then retire the original on GitHub. Use to archive, shelve or retire a repo, or to delete or clean up old repos and forks on GitHub. Skip zip or mail archives and a monorepo's own archive task.
---

# Archive project

The archive checkout's `AGENTS.md` owns the procedure; this skill adds the order and the gates. Find the checkout (default `~/src/archive`; ask when it is missing) and read that file first, also when you only delete a fork.

1. **Intent.** Settle with the user, for each repo, what happens to it: import then GitHub-archive, import then delete, import and keep, only GitHub-archive, only delete, or leave untouched. For a sweep such as "my old forks", list candidates with `gh repo list --fork` and settle them one by one. "Clean up" is not an end state: ask. Done when the user has named an end state for every repo.
2. **Import.** Skip for repos that are not imported. Follow that file from its scope check to the local archive commit and stop before Publish. Done when the archive's `status` lists the project and `git log -1 --format=%s` prints `archive <name>`.
3. **Publish.** Ask whether to push; only then follow its Publish step. Done when its checks pass.
4. **Retire.** Ask once per repo, naming it; only that answer counts. Then follow its retire step. Done when each original is in the state the user named; report the archive commit, the branches imported and what was retired.
