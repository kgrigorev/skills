# skills

- Scaffolds: shared files live in `skills/scaffold/_shared`; run `scripts/sync-scaffold-shared`
  after editing them. Read `skills/scaffold/GATES.md` before adding or changing a gate.
- Scaffold tests: `scripts/test-scaffold <stack> [case...]` replays `tests/scaffold/<stack>/*.sh`;
  its header explains the `# expect:` lines. To leave your own toolchains untouched, run it
  through `scripts/isolated-env`.
- CI logs: `scripts/ci-log <run id> [job] [step]` prints one job or step, cleaned.
- Merges: squash only. Land a stack with `skills/pull-request/scripts/land-squash-stack`.
- Commit messages and PR titles and bodies pass `scripts/no-ai-attribution` (`.githooks` and the
  `attribution` workflow run it): plain text, no tool credits, agent-file names or local commands.
  Enable the hooks with `git config core.hooksPath .githooks`.
