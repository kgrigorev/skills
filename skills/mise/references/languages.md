# mise recipes per language

Checked against mise `2026.11.3`. Docs: `mise.jdx.dev/lang/<language>.html`,
`mise.jdx.dev/dev-tools/backends/`. Who owns what per ecosystem:
[tasks-and-boundary.md](tasks-and-boundary.md).

## Choosing a backend

Write the registry shorthand (`ruff`, `golangci-lint`, `pnpm`) and mise picks the backend;
`mise registry <tool>` shows which. Write a prefix only to force a source. When you choose,
prefer the publisher's own prebuilt release:

1. `packslip:` (signed release manifest), then `aqua:` / `github:` / `gitlab:` / `forgejo:`
   (release binaries, no compile)
2. `http:` / `s3:` (archives at URLs you give)
3. language package backends: `npm:`, `pypi:` (alias `pipx:`), `cargo:`, `go:`, `gem:`,
   `dotnet:`, `spm:`, `conda:` (these need the runtime, or compile)
4. plugins last: `vfox:`, then `asdf:` (legacy, never on Windows)

`ubi:` is deprecated and removed in 2027.1.0; migrate to `github:`. The `pkgx:` backend is
gone. Core tools (node, python, go, rust, java, ruby, bun, …) need no prefix.

## Go

```toml
[tools]
go = "1.26"
golangci-lint = "2"                           # aqua binary, no compile
"go:github.com/pressly/goose/v3/cmd/goose" = "3"
"go:example.com/internal/tool" = { version = "latest", install_env = { GOPRIVATE = "example.com/*" } }

[tasks.test]
run = "go test ./..."
[tasks.lint]
run = "golangci-lint run"
```

mise sets `GOROOT`, and `GOBIN` unless you already set one. It never sets `GOPATH`. Install
Go CLIs as their own `go:` tools: a plain `go install` binary belongs to one Go version and
vanishes when you upgrade Go. With `go` in `idiomatic_version_file_enable_tools`, mise reads
`toolchain goX.Y.Z` (or an exact `go X.Y.Z`) from `go.mod`/`go.work`; a bare `go 1.26` is
ignored.

## Node, Bun, TypeScript

```toml
[tools]
node = "24"            # lts → 26 since 2026-10-28; pin the major you mean
pnpm = "10"            # or bun = "1", npm = "11"
"npm:@biomejs/biome" = "2"

[env]
_.path = ["{{ config_root }}/node_modules/.bin"]

[tasks.dev]
run = "pnpm dev"
[tasks.test]
run = "pnpm test"
```

- Pin the package manager as its own tool. Corepack is optional, enabled by the
  `node.corepack` _setting_, not a tool option.
- `.nvmrc`, `.node-version` and `package.json` `devEngines.runtime` are read only with
  `mise settings add idiomatic_version_file_enable_tools node --local`. `engines.node` is
  never read. For `packageManager`, enable `pnpm`/`yarn`/`npm` the same way.
- `npm:` tools install without node (embedded installer) and are checked against Sigstore
  provenance by default.

The package manager owns `package.json` deps, lockfile, workspaces and scripts. CLI, library,
or Vite app, the split is the same.

## nx monorepos

nx owns the project graph, cache and affected detection. mise pins tools and env, and adds
at most a few root verbs:

```toml
[tools]
node = "24"
pnpm = "10"

[env]
_.path = ["{{ config_root }}/node_modules/.bin"]

[tasks.install]
run = "pnpm install --frozen-lockfile"
[tasks.build]
run = "nx run-many -t build"
depends = ["install"]
[tasks.affected]
run = "nx affected -t build test lint"
```

## Python with uv

mise and uv can both install interpreters and venvs. Pick one owner for the interpreter: mise
installs Python and uv, uv manages the project env on top.

```toml
[tools]
python = "3.13"
uv = "0.11"
ruff = "latest"                  # aqua binary; other CLIs: "pypi:black" = "25"

[env]
UV_PYTHON = { value = "{{ tools.python.path }}", tools = true }   # uv uses mise's python

[settings]
python.uv_venv_auto = "create|source"   # needs uv.lock; "source" only activates

[tasks.test]
run = "uv run pytest"
[tasks.lint]
run = "uv run ruff check ."
```

- `python.uv_venv_auto` takes `false`, `"source"`, or `"create|source"`. `true` is
  deprecated.
- Without uv: `[env] _.python.venv = { path = ".venv", create = true }`.
- `mise sync python --uv` links mise's Pythons into uv, so uv finds them without
  downloading its own.
- Precompiled Pythons differ slightly from source builds; if a tool trips on that, set
  `python.compile = true`.

## Rust

mise drives rustup: it installs the toolchain into `RUSTUP_HOME`, sets `RUSTUP_TOOLCHAIN`,
and puts `$CARGO_HOME/bin` on PATH.

```toml
[tools]
rust = { version = "1.92", profile = "minimal", components = ["clippy", "rustfmt"], targets = ["wasm32-unknown-unknown"] }
"cargo:sqlx-cli" = "0.8"

[tasks.test]
run = "cargo test"
```

A `rust-toolchain.toml` is read only with `rust` in `idiomatic_version_file_enable_tools`.
Without that, `RUSTUP_TOOLCHAIN` from any mise `rust` entry (global included) overrides the
file. Check with `mise x -- rustup show active-toolchain`.

## C / C++

mise installs build tools and CLIs, not compilers, libc or system headers (use the OS package
manager).

```toml
[tools]
cmake = "4"
ninja = "1"
ccache = "4"
conan = "2"                      # pypi

[env]
CMAKE_GENERATOR = "Ninja"
CMAKE_CXX_COMPILER_LAUNCHER = "ccache"

[tasks.configure]
run = "cmake -B build -S ."
[tasks.build]
run = "cmake --build build"
depends = ["configure"]
[tasks.test]
run = "ctest --test-dir build"
```

`cmake_minimum_required` in `CMakeLists.txt` no longer selects a version.

## Scala and the JVM

```toml
[tools]
java = "21"                      # Temurin by default (java.shorthand_vendor)
scala-cli = "1"
# sbt = "1"                      # only for sbt projects

[tasks.test]
run = "scala-cli test ."
```

- Vendor-prefixed versions pin a build: `temurin-21`, `zulu-21`, `corretto-21`. Set
  `java.shorthand_vendor` in shared config if the team must stay on one vendor.
- `java@lts` is 25. `.java-version` and `.sdkmanrc` are opt-in idiomatic files.
- `JAVA_HOME` is set under `mise exec`, tasks and activated shells; shims alone set it only
  for the `java` process. If sbt or Gradle sees the wrong JDK, run it as
  `mise x -- sbt compile`.
- scala-cli owns the Scala version (`//> using scala`), deps and packaging.
