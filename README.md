# skills

Reusable agent skills in the open `SKILL.md` format, plus project scaffolds with local checks and
automation for agents. The skills work with Claude Code, Codex, Cursor and other compatible
harnesses.

| Skill | What it does |
| --- | --- |
| `commit` | Writes conventional git commit messages with short subjects and no AI attribution. |
| `pull-request` | Opens and updates GitHub PRs or GitLab MRs, manages stacked changes, and performs merges. |
| `mise` | Configures pinned tools, environment variables and mise tasks, and chooses between mise and ecosystem runners. |
| `type-design` | Makes illegal states unrepresentable and validates external input at boundaries. |
| `functional-core` | Separates decisions into pure functions from I/O in an imperative shell. |
| `test-design` | Starts with failing tests, checks outcomes and properties, and avoids mock-driven tests. |
| `audit` | Reviews a large codebase or subproject in bounded batches with parallel reviewers. |
| `fact-check` | Checks the claims in docs, PR bodies, commit messages and handoffs against the code, commands and history they describe. |
| `archive-project` | Moves a finished repository to an archive repository, verifies it, then retires the original after confirmation. |
| `ste100-replies` | Writes replies and repository text in ASD-STE100 Simplified Technical English, with a dictionary and checker script. |

### Scaffolding

Each skill in `skills/scaffold/` creates a new project with agent instructions and deterministic
quality gates. A project receives pinned tool versions and one `scripts/check` entry point. The git
hook, CI workflow and Claude Code Stop hook run the same gates.

| Skill | Stack |
| --- | --- |
| `scaffold-haskell` | Haskell: cabal, Ormolu, HLint, hspec, QuickCheck. |
| `scaffold-scala` | Scala 3 with Scala CLI: scalafmt, WartRemover, munit, ScalaCheck. |
| `scaffold-rust` | Rust: Clippy, rustfmt, cargo-nextest, cargo-deny, proptest. |
| `scaffold-go` | Go: golangci-lint with gofumpt, race-detector tests, rapid. |
| `scaffold-typescript` | TypeScript on Node with pnpm: tsc, oxlint, oxfmt, vitest, fast-check, knip. |
| `scaffold-python` | Python with uv: ruff, mypy, pytest, Hypothesis, branch coverage. |
| `scaffold-cpp` | C++ with CMake and pinned LLVM: clang-tidy, sanitizers, GoogleTest, rapidcheck. |
| `scaffold-c` | C23 with CMake and pinned LLVM: clang-tidy, sanitizers, Unity, libFuzzer. |

## Install

```sh
npx skills add kgrigorev/skills -g                    # every skill, for every project
npx skills add kgrigorev/skills -s pull-request -g    # one skill
npx skills add https://github.com/kgrigorev/skills/tree/main/skills/scaffold -g    # all scaffolds
npx skills update
```

While you change a skill, link it from your clone instead, so edits take effect at once:

```sh
ln -s ~/src/skills/skills/pull-request ~/.claude/skills/pull-request
ln -s ~/src/skills/skills/scaffold/scaffold-haskell ~/.claude/skills/scaffold-haskell    # scaffolds sit one level down
```

The scaffold skills share some files. Edit them in `skills/scaffold/_shared`, then run
`scripts/sync-scaffold-shared` to copy them into each skill.

## Contributing

Commits and PR text carry no AI attribution and use conventional commit subjects of at most 72
characters. `scripts/no-ai-attribution` checks this in CI. To run the same check before each
commit and push, run this once in the main checkout:

```sh
git config core.hooksPath "$(git rev-parse --show-toplevel)/.githooks"
mise trust && mise install
```

Use the absolute path. Git resolves a relative `core.hooksPath` in each worktree, and a worktree
of a branch cut before `.githooks` existed would run no hook at all.

`scripts/check` runs every repo gate locally, in `.githooks/pre-push` and in CI; `tests/check` and
`scripts/test-attribution` test them.
