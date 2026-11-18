# Reasons the template files cannot carry

Every other gate states its reason in a comment in its own file.

## Toolchain

- mise pins Go and golangci-lint, not `go.mod`. The `go` and `toolchain` lines in `go.mod` are
  minimums: a newer local Go builds the module anyway, and an older one downloads another Go.
  mise gives the same version everywhere, and `mise.lock` holds each download's checksum.
  `GOTOOLCHAIN=local` turns a mismatch into an error instead of a silent switch.
- The `go` line says `X.Y.0`, not the patch, so code that imports the module is not forced onto
  a patch release.
- golangci-lint comes from its release binary (mise's aqua backend), not from `go tool`. Its
  install page advises against `go tool`: that adds about 200 modules to the project's module
  graph and builds the linter with the local Go.
- CI uses no `actions/setup-go` and no `golangci-lint-action`. Each brings a second version pin
  that drifts from `mise.toml`, and the lint action's "only new issues" mode depends on the
  merge base.
- Go and golangci-lint are bumped together, as a pair. golangci-lint must be built with Go X.Y
  or newer, where X.Y is the `go` line of `go.mod` (a patch release does not matter), and its
  config keys change between versions.
- `scripts/check` and CI set `MISE_LOCKED=1`, so mise installs only the URLs and checksums in
  `mise.lock`. It is not `locked = true` in `mise.toml`: with it, `mise lock` for a new Go
  version writes an entry that mise then cannot install (mise 2026.11.8).
- Inside the project only `mise.toml` may configure mise. `scripts/check` asks mise which
  config files it loaded (`mise config ls`), so every other name (`mise.local.toml`,
  `.tool-versions`, `.config/mise/`, ...) is rejected without a list to keep current. Config
  outside the project (the user's global file) is the machine's business and absent in CI.
- No Brewfile: mise installs everything else. On Linux, the race detector needs a C compiler.
  On macOS it does not, since Go 1.20.

## Gates

- `-race` is on. Data races are the defect that agents add most quietly.
- No `-shuffle`. A random order makes the same commit pass or fail by chance. The weekly
  `explore` workflow runs random order and random property inputs instead, and govulncheck,
  whose database changes without a commit.
- Property tests use rapid, not `testing/quick`. `testing/quick` is frozen and cannot shrink a
  failing input to a small one.
- golangci-lint's `govet` runs every vet analyzer, so there is no separate `go vet` step.
- `GOENV=off` in `scripts/check` ignores settings saved with `go env -w`, such as a private
  `GOPRIVATE` or a company `GOPROXY`, and it clears the same module settings, the C compiler
  settings (`CC`, `CGO_*`), `GORACE` and `MISE_ENV` from the caller's shell before mise
  starts. Such settings go in the `[env]` table of `mise.toml`, which mise applies after.
  Module settings change where modules come from, not what they hold: `go.sum` still checks
  them.
- Files hidden by a build tag or a platform file name are rejected unless listed in
  `allowed_hidden` in `scripts/check`. Otherwise a `_linux.go` file would pass Linux CI and
  never be checked on macOS, so the result would depend on the machine.
- The module path falls back to `example.com/<package>`, not the bare package name. gofumpt
  treats a path without a dot in its first part as the standard library, and then gofumpt and
  gci disagree on the import order.
- The file checks start from `go list`, run with and without `-race`, not from git: lint and
  build see the files of a plain build, the tests those of a race build, and `./...` also
  includes files git ignores. Every Go file git sees must be in that list, and every package of
  the module that the code imports must be in `./...`. Otherwise code under `_x/`, `.x/`,
  `testdata/` or a nested module is built or kept without any check.
- A package "runs tests" when `go test -v` prints at least one `=== RUN` line for it. That
  also finds a `TestMain` that never calls `m.Run`, which still prints `ok`.
- golangci-lint skips files with a `Code generated ... DO NOT EDIT.` header by default. The
  template turns that off: such a header is one line any file can carry. A real generated file
  needs the owner's approval and an exclusion rule for its path.
- Known gaps, left to the reviewer (`CODING_STANDARDS.md` names them): a skip through another
  name (`skip := t.Skip`, a type that embeds `*testing.T`), a test that asserts nothing or
  returns early, a deleted test case, and a `TestMain` that narrows which tests run.
- The skip search matches the usual names of a test's `t` (`t`, `b`, `f`, `tb`, `tt`, `s.T()`),
  not every `.Skip(`: a reader or parser type with its own `Skip` method is ordinary code, and
  rejecting its callers would push agents to rename good APIs.
- `scripts/check` prints its first step, `Tools`, before it starts mise, so a failure inside
  mise (a pin that `mise.lock` lacks) is reported under a step too. `tests/scaffold/go` in
  `kgrigorev/skills` replays known attacks and good changes against each step.
- No coverage gate. A coverage number rises with tests that run code without checking it, the
  weak test it would be meant to catch, and agents then write tests for the number.
- The gate files are protected by `AGENTS.md` and the owner's review, not by a check: a check
  that reads its own config can be edited along with it. A project with several reviewers can
  add a `CODEOWNERS` file for them.

## Linters

- On by choice, although strict: `godoclint` on unexported names too (the Go form of "every
  top-level definition has a comment"), `gochecknoglobals` (sentinel `ErrX` errors are allowed)
  and `wrapcheck` (it can be noisy with interfaces; a project may add
  `ignore-interface-regexps` with the owner's approval).
- Left out: `revive` (its rules repeat staticcheck and godoclint), `varnamelen`, `wsl_v5`,
  `nlreturn`, `mnd`, `lll`, `godot`, `perfsprint`, `err113`, `exhaustruct`, `paralleltest`,
  `testpackage`, `ireturn`, `goconst`, `dupl`, `cyclop` and `gocyclo` (they overlap with
  gocognit), `contextcheck` (false positives), and `nolintlint` (`//nolint` is rejected
  outright). They are style opinions that find few defects, and agents spend turns on them.
  Linters for a specific library, such as `sloglint` or `testifylint`, come with that library.
- No exclusion presets. Each hides real findings, for example unchecked `Close` errors.
- `depguard` rejects `reflect` outside tests and `unsafe`, which `CODING_STANDARDS.md` puts
  behind the owner's approval. A cgo file imports `unsafe` too, so C code is rejected as well;
  depguard does not match `import "C"` itself. `any`, type switches and slice indexing stay
  allowed: they are ordinary Go, and the reviewer judges them.
- `forbidigo` names every way the library could print, log to a global logger or end the
  process (`fmt.Print*`, `os.Stdout`, `log`, `slog`'s package functions, `os.Exit`,
  `syscall.Exit`, `runtime.Goexit`, `panic`). `log.Fatal` exits, so it counts too.

## Claude Code

- `.claude/settings.json` (JSON has no comments):
  - `sandbox.filesystem.allowWrite` lists the folders Go, golangci-lint and mise write to, so
    `scripts/check` runs inside the sandbox without a bypass. All of `~/go/pkg` is listed,
    because Go writes the checksum database state to `~/go/pkg/sumdb`, next to the module
    cache. The telemetry folders are listed because plain `go` commands write counters there.
  - `sandbox.excludedCommands` holds `gh *`, because the macOS TLS check fails inside the
    sandbox. It only matches a plain `gh ...` call, without `cd`, a heredoc or a redirect.
  - `attribution` is empty, so commits and PRs describe the change only.
- `.githooks/pre-push` runs on push, not on commit, so small local commits stay fast.
- `.gitignore` lists `.idea/`. The Stop hook treats any untracked file as uncommitted work.

## Keeping the template current

- The template comes from a working project. When you improve a gate in a project made from it,
  port the change here. Then scaffold a scratch project and run its `scripts/check`.
- The versions sit at the top of `scripts/scaffold`. To bump, change them there, scaffold a
  scratch project and run its `scripts/check`. Keep `MISE_VERSION` in
  `.github/workflows/scaffold-go.yml` equal to `mise_version`.
- CI in `kgrigorev/skills` scaffolds a sample project weekly and on every change, verifies its
  golangci-lint config against the pinned version, lints its workflows and runs its checks.
- Project-specific material (domain terms, reference documents) stays out of the template.
- The template works with any set of agent skills. It names no skill and holds no convention that
  comes from one. A project adds those itself.
- The reader profile is an input, not fixed text. How much the comments explain depends on who
  reads the code.
