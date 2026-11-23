- Repo checks: run `scripts/check` before pushing or opening a PR; `tests/check` tests the gates.
  Read `skills/scaffold/GATES.md` before adding or changing a gate.
- Scaffolds: shared files live in `skills/scaffold/_shared`; run `scripts/sync-scaffold-shared`
  after editing them.
- Scaffold tests: `scripts/test-scaffold <stack> [attack...]` replays `tests/scaffold/<stack>/*.sh`;
  its header explains the `# expect:` lines. To leave your own toolchains untouched, run it
  through `scripts/isolated-env`.
- CI logs: `scripts/ci-log <run id> [job] [step]` prints one job or step, cleaned. `--attempt`
  reaches a re-run's earlier attempts.
- Merges: squash only. Land a stack with `skills/pull-request/scripts/land-squash-stack`.
  `tests/pull-request/land-squash-stack` tests it, and `scripts/check` runs that test.
- Commit messages and PR titles and bodies must pass `scripts/no-ai-attribution`, whose header
  lists the rules, among them a conventional subject of at most 72 characters. `.githooks` and the
  `attribution` workflow run it, and `scripts/test-attribution` tests it. Enable the hooks with
  `git config core.hooksPath "$(git rev-parse --show-toplevel)/.githooks"`: an absolute path,
  so worktrees of older branches still run them.
- Coding standards: read `CODING_STANDARDS.md` before editing or reviewing repository files.
