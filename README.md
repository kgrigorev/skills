# skills

Agent skills in the open `SKILL.md` format, for Claude Code, Codex, Cursor and other harnesses.

| Skill | What it does |
| --- | --- |
| `commit` | Writes short conventional commits without attribution. |
| `pull-request` | Opens small GitHub PRs and GitLab MRs with short bodies from the repo's template, stacks them, and merges them. |
| `mise` | Pins tools, env vars and tasks with mise; knows what belongs in mise vs other runners. |
| `type-design` | Makes illegal states unrepresentable; parses at boundaries. |
| `functional-core` | Keeps decisions in pure functions and I/O in a thin shell: read, calculate, write. |
| `test-design` | Tests seen red, properties over generated input, outcomes over calls. |
| `audit` | Splits a large codebase into batches and audits them in parallel. |
| `archive-project` | Imports a finished repo into your archive repo, checks the push, then retires the original on your word. |

### Scaffolding

The skills in `skills/scaffold/` each create a new project that agents can work in safely. Every
project gets one `scripts/check` that holds all quality gates, with pinned tool versions, so the
same commit gives the same result on every machine. The git hook, CI and the Claude Code Stop hook
all run it.

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
