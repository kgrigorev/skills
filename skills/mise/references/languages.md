# mise per-language recipes

Researched against mise `v2026.6.x`. Sources: `mise.jdx.dev/lang/*`,
`mise.jdx.dev/dev-tools/backends/*`, `mise.jdx.dev/mise-cookbook/*`.

Each section gives the idiomatic `mise.toml`, which **backend** installs what, the env vars
mise sets, and the **boundary** with the native tool (the part that keeps the repo clean —
see [tasks-and-boundary.md](tasks-and-boundary.md) for the doctrine).

## Table of contents

1. [Backends — choosing where a tool comes from](#backends--choosing-where-a-tool-comes-from)
2. [Go](#go)
3. [Node.js, Bun & TypeScript](#nodejs-bun--typescript)
4. [Nx monorepos](#nx-monorepos)
5. [Python with uv](#python-with-uv)
6. [Rust (systems / extensions)](#rust-systems--extensions)
7. [C / C++](#c--c)
8. [Scala with scala-cli](#scala-with-scala-cli)

---

## Backends — choosing where a tool comes from

A "backend" is how mise obtains a tool. Pick by this priority (earlier = preferred):

| Backend | Prefix | For | Notes |
|---|---|---|---|
| **core** | *(none)* | node, python, go, ruby, java, rust, .NET | Rust-native, fastest; sets `JAVA_HOME`/`GOROOT`/etc. |
| **aqua** | `aqua:` | 2000+ prebuilt CLI binaries | Reimplemented in mise; no aqua CLI needed. Preferred for binaries. |
| **github** | `github:` | binaries from GitHub Releases | Replaces deprecated `ubi:`; provenance verification, auto OS/arch. |
| **vfox** | `vfox:` | Lua plugins, cross-platform incl. Windows | Preferred plugin system over asdf. |
| **cargo** | `cargo:` | crates.io CLIs | Needs cargo; uses `cargo-binstall` if present. |
| **go** | `go:` | `go install` CLIs | Needs go. |
| **npm** | `npm:` | npm global CLIs | Needs node. |
| **pipx** | `pipx:` | Python CLI apps (isolated) | Uses `uvx` automatically if uv is installed. |
| **gem / dotnet / spm** | `gem:`/`dotnet:`/`spm:` | Ruby / .NET / Swift CLIs | Need the respective runtime. |
| **asdf** | `asdf:` | legacy community plugins | Last resort; arbitrary shell, no Windows, no new entries accepted. |

Registry shorthands (e.g. `golangci-lint`, `ripgrep`) resolve to a backend automatically — you
usually don't write the prefix for well-known tools. Use an explicit prefix to force a source.
`ubi:` is deprecated → migrate to `github:`.

---

## Go

```toml
[tools]
go = "1.26"
# Go-based CLI tooling via the go: backend
"go:github.com/pressly/goose/v3/cmd/goose" = "latest"
"go:mvdan.cc/gofumpt"                        = "latest"
# linter: prefer the prebuilt aqua binary over `go install` (much faster, no compile)
golangci-lint = "latest"                     # resolves to aqua:golangci/golangci-lint
# private modules during a tool install:
"go:github.com/acme/internal-tool" = { version = "latest", install_env = { GOPRIVATE = "github.com/acme/*" } }
```

**Env vars mise sets:** `GOROOT` (to mise's install; `go.set_goroot=true` default), optionally
`GOBIN`. `GOPATH` is **not** set by default (`go.set_gopath` is deprecated). Go-installed CLIs
land on `PATH` via mise's bin dir.

**Boundary:** mise owns the Go *version*, `GOROOT`/`GOBIN`, and Go-based CLI tools. Go owns
`go.mod`/`go.sum`/`go.work`, `go build`, `go test`, module resolution. In a `go.work`
workspace, mise just provides the toolchain — don't try to model workspace logic in mise.

```toml
[tasks.test]
run = "go test ./..."
[tasks.lint]
run = "golangci-lint run"
```

---

## Node.js, Bun & TypeScript

```toml
[tools]
node = "22"          # or "lts"
bun  = "latest"      # if the project uses bun
npm  = "11"          # pin a specific npm independent of node's bundled one (optional)
# CLI tools as global binaries
"npm:typescript"     = "latest"
"npm:@biomejs/biome" = "latest"

[env]
# make locally-installed bins (tsc, eslint, vite…) directly runnable
_.path = ["{{ config_root }}/node_modules/.bin"]

[settings]
# opt in to reading .nvmrc / .node-version / package.json engines (OFF by default)
idiomatic_version_file_enable_tools = ["node"]
```

Corepack (for pnpm/yarn pinned by `packageManager`): `node = { version = "22", corepack =
true }`, or manage the package manager explicitly with `npm:pnpm`.

**Boundary:** mise owns node/bun/npm *versions*, the `.bin` PATH entry, and global CLI tools.
The package manager (npm/pnpm/yarn/bun) owns `package.json` deps, lockfiles, workspaces, and
the `scripts`. mise tasks delegate:

```toml
[tasks.dev]
run = "pnpm dev"
[tasks.test]
run = "bun test"          # or "pnpm test"
```

**Project type doesn't change the boundary.** Whether it's a CLI tool, a library, a bunch of
scripts, or a Vite/React frontend, mise's job is the same: pin the runtime + package manager,
set env, expose `.bin`. Build/test/bundle stays in the package manager's scripts.

---

## Nx monorepos

The key decision: **nx owns the task graph; mise stays thin.** nx's value is its project
graph, affected detection, and (local/remote) caching — reimplementing nx targets as mise
tasks throws all of that away.

```toml
# repo-root mise.toml
[tools]
node = "22"
# pin the package manager too, for reproducibility:
"npm:pnpm" = "9"          # or use corepack

[env]
_.path = ["{{ config_root }}/node_modules/.bin"]   # nx, tsc, etc. directly runnable

[settings]
idiomatic_version_file_enable_tools = ["node"]

# Thin, top-level conveniences ONLY — call nx, don't replace it
[tasks.install]
run = "pnpm install --frozen-lockfile"
[tasks.build]
run  = "nx run-many -t build"
depends = ["install"]
[tasks.affected]
run = "nx affected -t build test lint"
```

| Concern | Owner |
|---|---|
| node + package-manager version | mise |
| env var injection | mise `[env]` |
| build/test/lint, caching, affected, codegen, project graph | **nx** |

Do not create one mise task per nx target. Add at most a few orchestration verbs at the root;
everything else goes through `nx`/`pnpm` directly.

---

## Python with uv

This is the ecosystem with the most mise/native overlap, because **both mise and uv can
install Python interpreters and manage venvs.** Pick one model and pin it; don't let both
manage the interpreter ambiguously.

**Recommended model (uv project with `uv.lock`):** mise installs the interpreter and `uv`;
uv manages the project environment on top; mise auto-activates the venv.

```toml
[tools]
uv     = "latest"
python = "3.12"

[settings]
# auto-activate an existing .venv when entering (needs a uv.lock present).
# string values; the old boolean form was removed in 2026.7.
python.uv_venv_auto = "source"          # or "create|source" to create then activate
```

Force uv to use mise's exact interpreter (avoids uv silently downloading its own):

```toml
[env]
UV_PYTHON = { value = "{{ tools.python.path }}", tools = true }
```

**Non-uv project (plain venv):** different mechanism, different code path:

```toml
[env]
_.python.venv = { path = ".venv", create = true }
```

**Python CLI tools** go through the `pipx:` backend (which uses `uvx` under the hood when uv
is present):

```toml
[tools]
"pipx:ruff" = "latest"
"pipx:mypy" = "latest"
```

**Boundary:** mise owns the *interpreter* version and `uv` version (and venv auto-activation);
uv owns `pyproject.toml`, `uv.lock`, dependency resolution, and running code. mise tasks
delegate to `uv run`:

```toml
[tasks.test]
run = "uv run pytest"
[tasks.lint]
run = "uv run ruff check ."
[tasks.type]
run = "uv run mypy"
```

(This repo's `learn/ai-native-engineering/mise.toml` is a clean real example of exactly this
pattern.) `mise sync python --uv` can align mise's and uv's interpreter lists if they drift.

---

## Rust (systems / extensions)

mise does **not** install Rust binaries directly — it installs/uses **rustup** and sets
`RUSTUP_TOOLCHAIN`. Toolchains live under rustup's control (`~/.rustup`, `~/.cargo`).

```toml
[tools]
rust = { version = "stable", profile = "minimal",
         components = "rust-src,rust-analyzer,clippy",
         targets = "wasm32-unknown-unknown" }
# cargo CLIs (use cargo-binstall automatically when available)
"cargo:sqlx-cli"   = "latest"
"cargo:cargo-pgrx" = "0.12.6"      # Postgres extension tooling
```

**Env vars:** `RUSTUP_TOOLCHAIN` (set to the requested version); `RUSTUP_HOME`/`CARGO_HOME`
respected if already set (override via `MISE_RUSTUP_HOME`/`MISE_CARGO_HOME`).

**`rust-toolchain.toml`:** mise reads it (channel/components/profile/targets) — when present,
don't duplicate the toolchain in `mise.toml`. CI may need `experimental = true`.

**Boundary:** mise owns the toolchain version + components/targets (via rustup) and `cargo:`
CLIs. rustup owns actual rustc/cargo binaries. cargo owns `Cargo.toml`/`Cargo.lock`,
`cargo build/test`. For Postgres/SQLite extension work, mise pins `cargo-pgrx`/`sqlx-cli`;
cargo+pgrx do the building.

```toml
[tasks.test]
run = "cargo test"
[tasks.build]
run = "cargo build --release"
```

---

## C / C++

**Fundamental limit:** mise does **not** install system compilers (gcc/clang), libc, or system
headers — use the OS package manager (apt/brew/pacman) for those. mise manages **build tools
and CLIs** plus env.

```toml
[tools]
cmake  = "3.30"
"github:ninja-build/ninja" = "latest"
ccache = "latest"
"pipx:conan" = "2"          # C/C++ dependency manager (or use vcpkg)

[env]
CMAKE_GENERATOR             = "Ninja"
CMAKE_CXX_COMPILER_LAUNCHER = "ccache"
CCACHE_DIR                  = "{{ config_root }}/.ccache"
```

**Boundary:** mise = build tools (cmake/ninja/ccache), CLIs (clang-format, protoc, buf),
env vars. OS package manager = compilers + system libs. conan/vcpkg = C/C++ library deps.
The build itself stays in cmake/ninja:

```toml
[tasks.configure]
run = "cmake -B build -S ."
[tasks.build]
run = "cmake --build build"
[tasks.test]
run = "ctest --test-dir build"
```

---

## Scala with scala-cli

```toml
[tools]
java      = "temurin-25"     # mise sets JAVA_HOME automatically (under `mise activate`)
scala-cli = "latest"
# sbt = "latest"             # only for legacy sbt projects

[settings]
java.shorthand_vendor = "temurin"   # then `java = "25"` means temurin-25

[env]
JAVA_OPTS = "-Xss4m"
```

JDK distributions: `temurin-25`, `zulu-25`, `corretto-25`, `openjdk-25`. Version files
`.java-version`/`.sdkmanrc` are read when enabled.

**Boundary:** mise owns the JDK version+distribution (`JAVA_HOME`) and the scala-cli/sbt
*version*. scala-cli owns the Scala version (`//> using scala …` directives), dependencies,
compilation, and packaging. mise tasks delegate:

```toml
[tasks.compile]
run = "scala-cli compile ."
[tasks.test]
run = "scala-cli test ."
[tasks.run]
run = "scala-cli run ."
```

**Gotcha:** `JAVA_HOME` may not refresh when switching projects unless `mise activate` is in
use. If sbt/Maven picks up the wrong JDK in automation, invoke through mise:
`mise exec -- sbt compile`.
