# mise tasks and the boundary with ecosystem runners

Checked against mise `2026.11.3`. Docs: <https://mise.jdx.dev/tasks/>. The rule itself (mise
is the front door, tasks _delegate_) is in [SKILL.md](../SKILL.md); this file holds how it
plays out per ecosystem, and the task syntax.

## Who owns what, per ecosystem

| Ecosystem | mise owns | Native tool owns | Task |
|---|---|---|---|
| Python + uv | interpreter, uv version, venv activation, env | `pyproject.toml`, `uv.lock`, running code | `uv run pytest` |
| Node / Bun | node, bun, package-manager versions, `.bin` on PATH | `package.json` deps and scripts | `pnpm test` |
| nx monorepo | node + package-manager versions, env | task graph, cache, affected | `nx run-many -t build`, root only |
| Go | go version, go-installed CLIs | `go.mod`, `go.work`, build, test | `go test ./...` |
| Rust | toolchain, components, targets (via rustup), cargo CLIs | `Cargo.toml`, build, test | `cargo test` |
| C / C++ | cmake, ninja, ccache, CLIs, env | compilers and system libs (OS), the build, deps (conan/vcpkg) | `cmake --build build` |
| Scala / JVM | JDK + vendor (`JAVA_HOME`), scala-cli/sbt version | Scala version, deps, packaging | `scala-cli test .` |

Recipes per ecosystem: [languages.md](languages.md).

**Logic goes in a mise task when it has no ecosystem home:** small or polyglot repos without
a runner, cross-language glue ("regen protobufs, build the Go server, build the TS client"),
CI orchestration, one-off ops scripts, or a team that chose mise as its task runner (tasks
still call `go`/`cargo` directly).

**Tie-breaker:** put the command where a contributor from that ecosystem looks for it
(`package.json`, nx target, `Makefile`), and let mise delegate to it.

## Anti-patterns

- **The same steps in two places** (`package.json` and `mise.toml`). Pick an owner; the
  other delegates.
- **One mise task per nx target or npm script.** Loses nx caching and affected detection,
  npm lifecycle hooks, and doubles the maintenance. A few root verbs at most.
- **`mise <task>` in committed scripts.** The shorthand collides with mise subcommands
  (`mise secrets` became a built-in in 2026.10.4 and broke tasks named `secrets`). Write
  `mise run <task>`.
- **`depends_post` for must-run cleanup.** It is skipped when the parent never starts. Use a
  `trap` in the script.
- **`{{ arg() }}` / `{{ flag() }}` in `run`.** Deprecated; removed in 2027.5.0. Use the
  `usage` spec below.
- **mise and uv both choosing the Python interpreter.** Pin the link with `UV_PYTHON` (see
  languages.md).

## TOML tasks

```toml
[tasks.build]
description = "Build the app"            # shown by `mise tasks`
run = "cargo build --release"            # string, or array of sequential steps
run_windows = "cargo build --release --features win"
dir = "{{ config_root }}"                # default: the project root
env = { RUST_BACKTRACE = "1" }
tools = { rust = "stable" }              # task-only tools, installed on demand
depends = ["codegen"]                    # run first, in parallel with each other
depends_post = ["notify"]                # run after, only if this task started
wait_for = ["lint"]                      # wait if lint is in this run; don't add it
sources = ["src/**/*.rs", "Cargo.toml"]  # skip when outputs are newer than sources
outputs = ["target/release/app"]         # or { auto = true }
skip_if = "test -f .skip-build"          # exit 0 → skipped, counts as success
lock = "test-db"                         # wait for other runs holding test-db
tags = ["ci", "slow"]                    # select with `mise run --tag ci`
timeout = "10m"
alias = "b"
confirm = "Build release?"
hide = false
quiet = false                            # hide mise's own lines for this task
raw = false                              # connect to the TTY; disables redaction
```

Write tasks with the CLI when you can: `mise tasks add build --sources 'src/**' -- cargo
build`, `mise tasks set build --description …`, `mise tasks rm build`. `mise tasks add
--force` replaces an existing one. `mise tasks validate` checks every task.

## File tasks

Executable scripts in a task directory (`mise-tasks/`, `.mise-tasks/`, `.mise/tasks/`,
`.config/mise/tasks/`, `mise/tasks/`). The path below the directory is the name, `/` becoming `:`
(`mise-tasks/db/migrate.sh` → `db:migrate`; `_default` takes its directory's name). Use a
file task once a `run` string grows conditionals or loops.

```bash
#!/usr/bin/env bash
#MISE description="Seed the database"
#MISE depends=["db:start"]
#USAGE arg "<env>" help="Target environment"
set -euo pipefail
echo "seeding ${usage_env}"
```

`#MISE` lines take every `[tasks.<name>]` key. The file must be executable on Unix.

## Arguments: the `usage` spec

```toml
[tasks.test]
usage = '''
arg "<file>" help="Test file" default="all"
flag "-w --watch" help="Re-run on change"
'''
run = 'cargo test "${usage_file?}"'
```

Each arg and flag becomes `$usage_<name>` (`-` → `_`), or `{{ usage.<name> }}` in a template.
Run with `mise run test my_test --watch`.

## Running tasks

```bash
mise run lint test build          # one DAG, parallel where deps allow (-j sets jobs)
mise run "test:*"                 # glob over a namespace
mise run --tag ci                 # every task tagged ci
mise run test -o summary          # a line per pass, full output of failures
mise run ci --report-file r.json  # JSON status of every scheduled task
mise run test --affected          # only where git changes touch the task's sources
mise run test --at main           # run at another revision in a temp worktree
mise run --dry-run build          # print order, run nothing
mise watch test --once            # wait for one change, run, exit
mise tasks ls --json              # machine-readable list
mise tasks deps build             # dependency tree
mise tasks log test               # last output (needs task.logs = true)
```

## Monorepos

Mark the root and list projects; tasks are then addressable by path:

```toml
# root mise.toml
monorepo_root = true
[monorepo]
config_roots = ["apps/web", "services/api"]
```

`mise run //services/api:test` from anywhere; `mise run :test` for the nearest project.
`task.auto_infer = ["node"]` (opt-in) imports workspace `package.json` scripts as tasks
without a `mise.toml` per package. In an nx or Turborepo repo, let that tool order the build
and call it from one mise task, rather than mirroring its edges in `depends`.
