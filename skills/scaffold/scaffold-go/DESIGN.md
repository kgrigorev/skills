# Reasons the template files cannot carry

Every other gate states its reason in a comment in its own file.
Before you add, change or review a gate, read
https://github.com/kgrigorev/skills/blob/main/skills/scaffold/GATES.md.

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
  settings (`CC`, `CGO_*`), `GORACE`, `GOCACHEPROG` and `MISE_ENV` from the caller's shell
  before mise starts. Such settings go in the `[env]` table of `mise.toml`, which mise applies
  after. Module settings change where modules come from, not what they hold: `go.sum` still
  checks them.
- The Modules step runs `go mod verify`. go compares `go.sum` with the module cache's hash
  files, but never hashes the cached source again, and the sandbox lets an agent write to the
  cache. An edited file there passed every local gate. `GOMODCACHE` is not cleared: the
  verification covers any cache, and a custom one is a common machine setting.
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
- A package "runs tests" when `go test -v` prints at least one `=== RUN` line for it and does
  not report `[no tests to run]`. Test code may print with `fmt.Print*` (examples need it), so a
  `=== RUN` line alone could be printed by the test code itself, for example from a blank
  variable in a package without tests.
- A `TestMain` needs the owner's approval: list its file in `allowed_testmain` in
  `scripts/check`. It runs before every test of its package and decides whether they run: it
  can skip `m.Run`, print a fake `=== RUN` line, or change `-test.run` or `-rapid.checks`
  first. An approved `TestMain` that never calls `m.Run` is still found by the `=== RUN` count.
- golangci-lint skips files with a `Code generated ... DO NOT EDIT.` header by default. The
  template turns that off: such a header is one line any file can carry. A real generated file
  needs the owner's approval and an exclusion rule for its path.
- Test skips (`Skip`, `Skipf`, `SkipNow` on any `testing` type, rapid's `t.Skip`,
  `testing.Short` and `testing.Verbose`) are found by forbidigo with `analyze-types`, which
  matches what a name refers to. So a `*testing.T` named `x`, a `testing.TB` helper parameter,
  a method expression and a method value (`skip := t.Skip`) are all found, and a reader type
  with its own `Skip` method is not. A text search on `.Skip(` could do neither.
  `testing.Verbose` counts because `scripts/check` always passes `-v`: a test that returns
  under it skips itself in every gate run and runs only in a plain `go test`.
- forbidigo checks `Example` functions like other test code (`exclude-godoc-examples: false`).
  By default it skips them, and an example without an `Output` comment is never run as one, so
  it is a plain function any test code could call to print or read the environment. Test files
  may use `fmt.Print*`, which examples need; `os.Stdout`, `os.Stderr` and `println` stay
  forbidden.
- Only a command reads the environment (`os.Getenv` and friends, and `exec.Cmd.Environ`, are
  forbidden elsewhere, tests and examples included). A setting read in the library is a hidden
  input, and a test that reads one can skip itself (`if os.Getenv("SLOW") == "" { return }`),
  the same as `testing.Short`. The command line is a hidden input in the same way, so
  `os.Args`, `os.Executable` and the global flag set (`flag.Parse`, `flag.Set`, ...) are a
  command's too. `flag.Set` in a test could also set `-rapid.checks` to 0. A `flag.FlagSet`
  made with `flag.ContinueOnError` stays allowed.
- `testing.Testing` is forbidden everywhere: code that asks whether it runs under test lets a
  test check something production never runs.
- "A command" is package main directly in `cmd/<name>/`, without its tests. Only its files may
  print, exit, panic, read the environment or make raw system calls, and only it may run no
  tests, as long as it declares no function or method but `main` and `run`. funlen and gocognit
  keep those two short; any other function is logic, so the command then needs a test, or the
  whole feature could sit in package main untested. Packages below it (`cmd/<name>/internal/`)
  are library code: otherwise logic moved there would skip every library rule. A package
  directly in `cmd/` must be package main.
  The path in `.golangci.yml` spells out "not `_test.go`", because Go regexps have no
  lookahead and golangci-lint does not allow `path` and `path-except` in one rule.
- `syscall` and `golang.org/x/sys` are forbidden outside a command: raw system calls write to
  file descriptor 1 or kill the process past every name forbidigo lists. So are `os.NewFile`
  (a terminal by file descriptor), `os.Stdin` (on a terminal, file descriptor 0 is open for
  writing) and `os.FindProcess` (a handle on the program's own process).
- Assembly, C, C++, Objective-C, Fortran, SWIG and `.syso` files are rejected unless listed in
  `allowed_foreign` in `scripts/check`. `go list` names them, so no file list is kept here. A Go
  function without a body can run any assembly, and no linter or test reads it.
- `//go:norace` is rejected: it turns the race detector off for one function. So is
  `//godoclint:disable`, which switches the doc comment rule off for a file.
- Line directives (`//line`, `/*line*/`) are rejected. They change the file and line that
  golangci-lint reports, so a library function could claim to sit in `cmd/` and escape the
  library rules.
- No PATH entry may point into the project, and `go` and `golangci-lint` must resolve to the
  files `mise which` names. `mise.toml` is the one allowed mise config, and its `_.path` could
  otherwise put a fake tool (or a fake `mise`, `sed` or `awk`) first.
- `scripts/check` prints its first step, `Tools`, before it starts mise, so a failure inside
  mise (a pin that `mise.lock` lacks) is reported under a step too. `tests/scaffold/go` in
  `kgrigorev/skills` replays known attacks and good changes against each step.
- No coverage gate. A coverage number rises with tests that run code without checking it, the
  weak test it would be meant to catch, and agents then write tests for the number.

## Not closed

Known ways past the checks, left to the reviewer. `CODING_STANDARDS.md` names the ones a code
review must look for. `tests/scaffold/go` holds no case for them, since each would pass.

- Edits to the gate files: `.golangci.yml` (`default: none` with one harmless linter, an
  exclusion rule for a library path), `scripts/check`, `mise.toml`, `mise.lock` and the
  workflows. They are protected by `AGENTS.md` and the owner's review, not by a check: a check
  that reads its own config can be edited along with it. A project with several reviewers can
  add a `CODEOWNERS` file for them.
- A test that asserts nothing (`_ = Double(2)`), or that returns early on a condition other than
  the environment, `-short` and `-v`. The check sees that a test ran, not what it checked. A
  deleted test case, an approved `TestMain` that narrows which tests run, and a fuzz target
  without seeds (`f.Add`), which counts as run but never calls its body, the same.
- An error turned into a zero value in a function with no error result
  (`if err != nil { return nil }`). `nilerr` only covers functions that return an error, and
  "nil means not found" is sometimes the right design.
- Work at import time through a blank variable (`var _ = setLang()`). `gochecknoinits` only
  sees `func init`, and `gochecknoglobals` skips `_`. Telling it from the idiomatic
  `var _ Interface = (*T)(nil)` needs type information that no enabled linter uses.
- A skip through a type declared in the module: a helper type that embeds `*testing.T`, an
  interface (`var s interface{ Skip(...any) } = t`) or a type parameter
  (`func later[T interface{ SkipNow() }](t T)`). forbidigo names the call after that type, not
  after `testing`. Or a skip through `reflect` in a test (tests may import `reflect` for
  `DeepEqual`).
- An edited build cache (`~/.cache/go-build`): go trusts what it finds under a key. Only CI,
  which starts from its own cache, sees it.
- Printing or exiting through a path or another program: `os.OpenFile("/dev/stdout")`, or
  `os/exec` running `kill`. A path is a string built at run time.

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
  process that does not go through a path or another program (`fmt.Print*`, `os.Stdin`,
  `os.Stdout`, `os.Stderr`, `os.NewFile`, the `log` and `slog` package functions, `os.Exit`,
  `os.FindProcess`, `syscall`, `runtime.Goexit`, `panic`, and the `Fatal` and `Panic` methods of
  a `*log.Logger`). `log.Fatal` exits, so it counts too. A `*slog.Logger` or `*log.Logger`
  passed in as a parameter is allowed: that is how the library logs. With `analyze-types`, an
  import alias does not hide a name.
- errcheck lets a command's own files drop the error of `fmt.Fprint*`: a command that reports a
  failure on stderr has nowhere left to report a failed write, and the idiomatic
  `run(args, stdout, stderr io.Writer) int` would otherwise need a contortion.

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
