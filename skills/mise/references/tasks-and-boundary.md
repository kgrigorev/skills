# mise tasks & the mise-vs-tools boundary

Researched against mise `v2026.6.x`. Sources: <https://mise.jdx.dev/tasks/> and the
maintainer's design statements on GitHub (notably the rejected transparent-delegation
request, Discussion #6778).

This file has two halves: (1) how the task system works, (2) the doctrine for deciding who
owns what. The doctrine is the part that keeps real repos clean — read it even if you only
came for syntax.

## Table of contents

1. [Task system — the two flavors](#task-system--the-two-flavors)
2. [TOML task fields](#toml-task-fields)
3. [File tasks](#file-tasks)
4. [Arguments: the `usage` spec](#arguments-the-usage-spec)
5. [Dependencies, ordering, parallelism](#dependencies-ordering-parallelism)
6. [Up-to-date checks: `sources`/`outputs`](#up-to-date-checks-sourcesoutputs)
7. [Running tasks](#running-tasks)
8. [The boundary doctrine](#the-boundary-doctrine)
9. [Per-ecosystem ownership](#per-ecosystem-ownership)
10. [Anti-patterns](#anti-patterns)

---

## Task system — the two flavors

- **TOML tasks** — declared in `mise.toml` under `[tasks.<name>]`. Best for short commands and
  declarative wiring (deps, env, sources/outputs). Most tasks should be these.
- **File tasks** — executable scripts discovered in `mise-tasks/`, `.mise/tasks/`,
  `.config/mise/tasks/`, or a `tasks/` dir. Best when the logic is more than a line or two —
  real scripts in bash/python/node/etc. with a `usage`-spec header for args. Keeps complex
  logic out of TOML.

Both are invoked the same way (`mise run <name>`). Prefer file tasks once a `run` string
would contain shell logic, conditionals, or loops — TOML is for wiring, not programming.

## TOML task fields

```toml
[tasks.build]
description = "Compile the project"      # shown in `mise tasks`
run = "cargo build --release"             # string, or array for sequential steps
# run = ["step one", "step two"]
run_windows = "cargo build --release --features win"  # platform override
dir = "{{ config_root }}"                 # working directory
env = { RUST_BACKTRACE = "1" }            # task-only env vars
tools = { rust = "stable" }               # task-only tool versions (installed on demand)
depends = ["codegen"]                     # run these first (parallel unless ordered by data)
depends_post = ["notify"]                 # run these AFTER (only if this task actually started)
wait_for = ["optional-thing"]             # if it's running, wait — but don't schedule it
sources = ["src/**/*.rs", "Cargo.toml"]   # inputs for freshness check
outputs = ["target/release/app"]          # outputs; or `outputs = { auto = true }`
alias = "b"                               # `mise run b`
confirm = "Build release?"                # prompt before running
hide = false                              # exclude from `mise tasks` listing
quiet = false                             # suppress mise's own chatter
raw = false                               # connect directly to the TTY (disables redaction/capture)
usage = 'arg "<target>" help="what to build"'   # CLI args — see below
```

## File tasks

A file task is just an executable script in a tasks directory. Put metadata in a comment
header using the `usage` spec, and mise treats it as a first-class task:

```bash
#!/usr/bin/env bash
#MISE description="Seed the local database"
#MISE depends=["db:start"]
#USAGE arg "<env>" help="target environment"
set -euo pipefail
echo "seeding ${usage_env}"          # usage args arrive as $usage_<name>
```

mise loads the project's tools+env before running the script, so the right `psql`/`node`/etc.
is on `PATH` automatically — no `mise exec` needed *inside* a task.

## Arguments: the `usage` spec

The current, supported way to declare task arguments and flags. It generates parsing, help,
and completions:

```toml
[tasks."test:one"]
usage = '''
arg "<number>" help="Exercise number"
flag "--watch" help="Re-run on change"
'''
run = 'uv run pytest tests/exercise_{{ arg(name="number") }}'
```

Within `run`, reference args via the `arg()`/`flag()` template functions **inside the usage
model**, or in file tasks via `$usage_<name>` environment variables. (Older free-floating
Tera `{{arg()}}` without a `usage` block is deprecated — removal targeted for late 2026.)

Invoke with `mise run test:one -- 3 --watch` (everything after `--` is passed to the task).

## Dependencies, ordering, parallelism

- `depends` — prerequisites; run before this task, **in parallel** with each other unless a
  data dependency forces order. mise builds a DAG across all requested tasks and runs the
  maximum it safely can in parallel (`--jobs`, default 8).
- `depends_post` — run *after* this task **only if this task actually started**. Do **not**
  use it for cleanup that must always run (if the parent is skipped as up-to-date, post-deps
  don't fire). For guaranteed cleanup use a `trap` inside the `run` script.
- `wait_for` — "if X happens to be in this run, wait for it; otherwise ignore" — soft
  ordering without forcing the dependency to execute.

```bash
mise run lint test build          # runs all three, parallel where the DAG allows
mise run "test:*"                 # wildcard over a namespace
mise run lint ::: test            # ::: separates independent task chains
```

## Up-to-date checks: `sources`/`outputs`

When a task declares `sources` (inputs) and `outputs`, mise skips it if outputs are newer
than all sources — a make-like incremental build. `outputs = { auto = true }` lets mise infer
output tracking. This is what makes mise tasks viable as a light build orchestrator without
reaching for Make.

## Running tasks

```bash
mise run <task>            # canonical
mise run <task> -- args    # pass args through
mise <task>                # shorthand — AVOID in shared scripts (collides with mise subcommands)
mise run                   # interactive picker
mise watch <task>          # re-run on file change (watchexec)
mise tasks                 # list; mise tasks --json for machine reading
mise run --output prefix … # interleaved, prefixed output for parallel runs
```

Prefer the explicit `mise run <task>` form in committed scripts, docs, and CI. The bare
`mise <task>` shorthand is convenient interactively but risks shadowing a real subcommand and
is ambiguous to readers.

---

## The boundary doctrine

**mise owns provisioning + entrypoints; ecosystem runners own logic.** Concretely:

**mise OWNS:**

1. **Tool/runtime versions** — `[tools]`.
2. **Environment & secrets** — `[env]`, dotenv, `PATH`, redactions.
3. **The canonical entrypoints a human/CI types** — a small, stable, polyglot verb set:
   `mise run {dev,build,test,lint,fmt,typecheck,ci}`. These are the "front door."

**Ecosystem runners OWN the build/test/lint logic:** `package.json` scripts, `uv run`,
`cargo`, `nx`, `scala-cli`, `go`, `cmake/ctest`.

**The bridge: mise tasks delegate, never duplicate.**

```toml
[tasks.test]
run = "uv run pytest"
[tasks.lint]
run = "npm run lint"
[tasks.build]
run = "nx run-many -t build"
```

**Why this split (the reasoning, not a rule to memorize):**

- *Feature preservation* — delegating keeps the native tool's full power (nx's affected
  graph and remote cache, npm lifecycle scripts, cargo profiles). A reimplemented mise task
  silently loses these.
- *No magic fallthrough* — mise deliberately does **not** auto-proxy `mise run x` to
  `npm run x`. The maintainer rejected that because a proxied task wouldn't get mise's full
  task feature set. So delegation must be explicit (`run = "npm run x"`). Don't design around
  a fallthrough that doesn't exist.
- *Additive, not migratory* — mise becomes a uniform entrypoint layered over whatever each
  subproject already uses, so adopting it doesn't require rewriting build logic.

**When logic legitimately lives _in_ a mise task** (not just delegation):

- Small or polyglot repos with no established native runner.
- Cross-ecosystem glue: "regenerate protobufs → build the Go server → build the TS client."
- CI orchestration and one-off operational scripts.
- A repo where mise IS the chosen task runner by team decision (then mise tasks are
  first-class, and they still call `go`/`cargo`/etc. directly).

**When to keep mise thin and defer:**

- **nx monorepos** — nx owns the task graph, caching, and affected detection. mise pins
  node/pnpm and sets env; it should not wrap individual nx targets beyond a couple of
  top-level conveniences. Reimplementing nx targets as mise tasks throws away nx's value.
- Repos with an established `package.json`-scripts culture the team relies on — keep scripts
  where contributors expect them; add at most thin mise mirrors for cross-language
  uniformity.

A useful tie-breaker: **if a competent contributor in that ecosystem would expect the command
somewhere specific** (`package.json`, `Makefile`, nx target), put the logic there and let mise
delegate. Use mise's own task body only for things that have no natural ecosystem home.

## Per-ecosystem ownership

| Ecosystem | mise owns | Native tool owns | mise task pattern |
|---|---|---|---|
| **Python + uv** | python interpreter, `uv` version, venv activation, env | deps (`pyproject.toml`/`uv.lock`), running | `run = "uv run pytest"` |
| **Node/Bun/TS** | node/bun/pnpm versions, `PATH` to `.bin`, env | `package.json` deps + scripts | `run = "pnpm test"` / `run = "bun test"` |
| **nx monorepo** | node + package-manager version, env | the entire task graph, cache, affected | thin: `run = "nx run-many -t build"` only at top level |
| **Go** | go version, `GOROOT`/`GOBIN`, go-installed CLIs | modules, `go build/test`, `go.work` | `run = "go test ./..."` |
| **Rust** | toolchain via rustup, components/targets, cargo CLIs | `Cargo.toml`/`.lock`, `cargo build/test` | `run = "cargo test"` |
| **C/C++** | cmake/ninja/ccache/conan, env (generator, launcher) | the build itself (cmake/ninja), libs (conan/vcpkg) | `run = "cmake --build build"` |
| **Scala** | JDK + distribution (`JAVA_HOME`), scala-cli/sbt versions | scala version directives, deps, packaging | `run = "scala-cli test ."` |

Per-ecosystem `mise.toml` recipes, backends, and env-var details: [languages.md](languages.md).

## Anti-patterns

- **Duplicating logic in two places** — the same build steps in both `package.json` and
  `mise.toml`. Pick the owner; the other delegates. Drift is guaranteed otherwise.
- **Reimplementing a mature runner** — recreating nx targets or npm scripts as hand-written
  mise tasks. You lose caching/affected/lifecycle and gain a maintenance burden.
- **Using bare `mise <task>` in committed scripts** — collides with subcommands and reads
  ambiguously. Use `mise run <task>`.
- **`depends_post` for must-run cleanup** — it's skipped when the parent doesn't start. Use a
  `trap` in the script.
- **Expecting env in non-interactive shells without `mise exec`/`mise run`** — `mise activate`
  hooks the prompt; a task or `mise exec` is what loads env in automation. (See
  [troubleshooting.md](troubleshooting.md).)
- **Deprecated Tera arg functions** — use the `usage` spec for task arguments.
- **uv-vs-mise Python double management** — letting both manage the interpreter without
  pinning the link. Decide one model (see [languages.md](languages.md) Python section).
