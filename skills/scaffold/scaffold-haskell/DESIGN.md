# Reasons the template files cannot carry

Every other gate states its reason in a comment in its own file.
Before you add or change a gate, read `skills/scaffold/GATES.md` in kgrigorev/skills.

- `.claude/settings.json` (JSON has no comments):
  - `sandbox.filesystem.allowWrite` lists the cache and state folders of cabal and mise, so
    `scripts/check` runs inside the sandbox without a bypass. `~/.ghcup` and `~/.config/cabal`
    are left out on purpose. Installing GHC is an owner step. The cabal user config can add
    compiler options (`program-default-options`), so agents must not write it, although
    `scripts/check` no longer reads it for builds (see Gates). The README's `cabal update`
    creates it once during setup.
  - `sandbox.excludedCommands` holds `gh *`, because the macOS TLS check fails inside the
    sandbox. It only matches a plain `gh ...` call, without `cd`, a heredoc or a redirect.
  - `attribution` is empty, so commits and PRs describe the change only.
- `.githooks/pre-push` runs on push, not on commit, so small local commits stay fast.
- `.gitignore` lists `.idea/`. The Stop hook treats any untracked file as uncommitted work.

## Tools

- mise pins cabal, ghcup, Ormolu, cabal-gild and HLint, and `mise.lock` holds their checksums.
  Before, Homebrew installed them locally without a version pin and CI pinned them separately,
  so the two drifted. `locked = true` makes mise install only what the lock records.
- GHC is not in mise: mise has no working GHC entry. `with-compiler` in `cabal.project` pins it,
  because cabal and HLS already obey that line, and ghcup installs it.
- `scripts/check` accepts only ghcup's GHC. Homebrew's GHC of the same version has another ABI
  hash, so switching between the two silently rebuilds the cabal store, and HLS builds expect
  ghcup's GHC. `GHCUP_USE_XDG_DIRS` is not supported: the check then fails with the install hint.
- ghcup reads its download list live. A released GHC tarball and its checksum do not change, so
  this is accepted. Pinning the list to one commit is possible but not done.
- HLint 3.10 is the newest release. Its asset named `x86_64-osx` holds an arm64 binary (checked
  with `lipo -info`), so `mise.toml` points Apple Silicon at it. The lock covers only linux-x64
  and macos-arm64; other platforms fail in `mise install`. When a new HLint ships a correctly
  named arm64 asset, drop the `asset_pattern` override and run `mise lock` again.
- `scripts/check` runs itself again under `mise exec --`. Agent command tools, git hooks,
  editors and the Stop hook run without mise's shell hook, and in such a shell `cabal`, `ormolu`
  and `hlint` may find unpinned Homebrew copies. The other scripts call `mise exec --` too.
- `scripts/check` makes mise read only the project's `mise.toml`: it points
  `MISE_GLOBAL_CONFIG_FILE` at a path that cannot exist, sets `MISE_CEILING_PATHS` to the parent
  folder and unsets `MISE_ENV`. Then it fails when `mise config ls` lists any other file, so a
  committed `mise.local.toml` or `.tool-versions` cannot put other tools first, also in CI, which
  trusts the whole workspace. The user's global tools and `[env]` stay out of the checks. A
  project under the home folder would otherwise read `~/.config/mise/config.toml` as a project
  config.
- `scripts/check` compares each tool on PATH with `mise which`. A mise install without its
  binary (seen with HLint) otherwise falls through to a Homebrew copy with other rules, and
  `SCRIPTS_CHECK_UNDER_MISE=1` set by a caller would skip mise. Either now fails.
- `min_version` in `mise.toml` is a floor for mise itself. Only CI pins mise exactly.

## Gates

- `cabal.project.freeze` pins every dependency version, so a version change shows in review and
  CI can key its cache on it. The gate solves again into a temporary project that imports
  `cabal.project` and compares. It never writes the committed file.
- The format, lint and switch-off steps take their file lists from git, so a new component
  folder, such as `bench/`, is covered. `cabal.project` sets `benchmarks: True`, because
  `cabal build all` skips benchmarks otherwise. The lists are split at whitespace with globbing
  off, so a folder named `bench/[a]` stays that name, and every name starts with `./`, so a file
  named `-o-optP.hs` is not read as an option (HLint took it as `--only` and checked nothing).
  The check rejects `.hs` and cabal file names with spaces, control characters or double quotes,
  which git prints quoted or the split breaks, and an upper-case `.HS`, which GHC finds on a
  macOS disk. Such a file would drop out of every list. The other Haskell extensions are matched
  in any case. GHC also compiles `.lhs`, `.hsc`, `.hs-boot`, `.hsig`,
  Alex, Happy and c2hs sources, which Ormolu and HLint do not read, so `scripts/check` rejects
  them, and git-ignored `.hs` files outside `dist-newstyle/`, which pass locally and are missing
  in CI.
- The switch-off step reads each `.hs` file whole (perl), because HLint and GHC accept a pragma
  or an `HLINT ignore` comment split over several lines. It first splits the file the way GHC
  lexes it: nested block comments, line comments, string and character literals. A regex over
  the raw text read `"--"` or `"{-"` in a string as a comment start and skipped real code after
  it, and read a word in a string as code. The file is read as UTF-8, and names and operators
  must be ASCII; strings, characters and comments may hold any text, except the first word of a
  block comment, where pragma names go. perl and GHC class other characters differently, and
  each attempt to match GHC's classes left a gap: read as bytes, `'λ'` paired the quotes after
  it wrongly; `∘--` and `‿--` are operators to GHC and comments to perl's `\w`; GHC 9.14 knows
  symbols from newer Unicode versions than perl (`⿼--`); and GHC lower-cases `İ` to `i` in
  `OPTİONS_GHC`, which perl's case folding does not match. Pragmas are searched for in comments only, code rules in code
  only. `ANN`, `OPTIONS` and `COMPLETE` count only as pragmas (`{-#`), so a comment such as
  `{- Annual totals -}` passes. `COMPLETE` tells `-Wincomplete-patterns` that some constructors
  cover a type. `OPTIONS_HADDOCK` changes only the docs and is allowed; for Ormolu only
  `ORMOLU_DISABLE` and `ORMOLU_ENABLE` count, so a comment that starts with "Ormolu" passes.
- Escape hatches are matched by where they come from, not by every name: imports of another
  package's module with an `Unsafe` or `Internal` part in its name (`Data.ByteString.Internal`
  exports `accursedUnutterablePerformIO`), `unsafe*` names in an import list, and `unsafe*` names
  used through the qualifier of another package's module (`IO.unsafeIOToST`). HLint bans only
  exact names, and base re-exports unsafe functions from many modules (`GHC.IO`, `GHC.Exts`).
  `-Wmissing-import-lists` makes every other import name what it brings in, also with `hiding`,
  so these three cover them all. The project's own modules are exempt: a local `unsafeChars` or a
  `SampleTool.Internal` module is fine. GHC resolves module names per component, so the
  exemption does too: a file may use the modules of the components whose source folders hold
  it, and the libraries' exposed modules. Only components of the `.cabal` files that
  `cabal.project`'s `packages` name count, with the common stanzas they import, outside `if`
  blocks. So a `module` line in a file that no component builds (`docs/Example.hs` with
  `module GHC.IO`), a list under `if false`, in an unused common stanza, outside every stanza or
  in another component does not exempt base's module. A `.cabal` file that no `packages` entry
  names is rejected: no build reads it. `mixins` and `reexported-modules` may not rename a
  module: `Data.Text.Unsafe as SampleTool.Fast` would hide the `Unsafe` name.
- `foreign import` is rejected: GHC2024 turns on the FFI, and a C function with a pure type is
  an `unsafePerformIO` that no step reads.
- `module M (module M)` is rejected: it exports every name, so `-Wunused-top-binds` never sees
  dead code.
- Flags in `.cabal` and `cabal.project` files are checked against a list of allowed flags (the
  warning list, `-Werror`, `-threaded`, `-rtsopts`, `-with-rtsopts=`, `-O`), not against bad
  ones. GHC also reads flags from response files (`@file`), runs preprocessors (`-F -pgmF`) that
  can add an `OPTIONS_GHC` line no step sees, and has many spellings for "warnings off". Other
  `*-options` fields are not allowed. In `.hs` files GHC reads flags only from an `OPTIONS`
  pragma, which the step rejects whole, so there `-w` is text, such as a command-line option.
- `cabal.project` may set only `packages`, `tests`, `benchmarks`, `with-compiler`, `index-state`,
  `optimization`, `constraints`, `allow-newer` and `allow-older`, plus `package` stanzas with
  `ghc-options` and `flags` and `source-repository-package` stanzas, whose `tag` must be a full
  commit hash: a branch moves, and no step reads the code it points to. cabal also reads test
  options, a test wrapper, program options and other files (`import:`) from it.
- The build settings step parses the `.cabal` file: every component starts with
  `import: common`, extensions and the language are set only in `common common` (a component
  could switch GADTs or CPP back on, and HLint lints only one branch of `#if`), no `buildable`
  field (an unbuildable component hides its type errors), `build-type: Simple`, and every
  `hs-source-dirs` and `packages` entry is a folder inside the project that git does not ignore.
  The format, lint and switch-off steps read only files git sees, so a source folder under
  `dist-newstyle/` would skip them.
- From the freeze step on, `scripts/check` runs cabal with a config file of its own: the Hackage
  repository, and the index and store folders that the user's config names. cabal reads
  compiler and test options from its user config (`program-default-options`, `test-wrapper`),
  and `CABAL_CONFIG`, also set in `mise.toml`'s `[env]`, can point it at any file. Other
  settings of the user's config, such as an extra repository, do not apply to the check.
- The warning list lives twice: in the `common common` stanza, where GHC and HLS read it, and in
  `scripts/check`, which fails when the stanza loses a flag or a component does not start with
  `import: common`. A new component would otherwise build without `-Wall`. The `-Werror` stanza
  in `cabal.project` must name the package from the `.cabal` file, and `cabal.project` may not
  `import:` other files, which no step reads. Passing the flags on the command line
  (`--ghc-options`) would need no list, but cabal then rebuilds the package every time someone
  switches between `cabal build` and `scripts/check`.
- Every test suite's `main-is` must be exactly the hspec-discover driver line, and its
  `other-modules` must be `*Spec` modules under the driver's folder (hspec-discover runs only
  those) or modules that test code imports with a non-empty list (`import M ()` brings in
  nothing). A module may be in only one source folder of a component: GHC compiles the first
  one it finds, so a passing copy in another folder would replace the spec that hspec-discover
  found. A hand-written `Main` or a spec module with
  another name would run only some tests, or none. A `SpecHook.hs` under a driver's folder is
  rejected: hspec-discover applies its hook to every spec in the folder, and the hook can
  replace them. The test step passes `--failure-report`, which hspec writes at the end of a run,
  and expects a report for every `test-suite`. Counting the summary lines in the output did not
  work: a test can print a summary and exit with code 0 before the other examples run. The
  report path is on the test's own command line, so HLint bans the ways a test reaches it and
  stops hspec early with base and hspec alone: `runIO`, `hspec*`, `GHC.Environment`, and
  `getArgs` and `withArgs` outside `Main`.
- HLint bans the settings that make a test check less or invert it: `expectFailure`, `once`,
  `withMaxSuccess`, `withNumTests` and the other `with*` and `modify*` settings, hspec's
  `Test.Hspec.Core.*` and `Test.Hspec.Runner` modules, which can turn a suite into a dry run,
  the `around*` hooks, which decide whether an example runs at all (`before` and `after` stay
  allowed), `Test.QuickCheck.Property`, whose `mapTotalResult` turns a failure into a pass,
  `mapSize`, and the `quickCheck*` runners, which print a failure and return `()`.
- HLint bans by module where a name is total elsewhere: `Data.Text.index` and
  `Data.List.NonEmpty.fromList` are banned, `Data.List.NonEmpty.head` is allowed although
  `head` is banned. `System.Exit` and `GHC.IO.Exception` (which also exports `ExitCode`) are
  allowed only in `Main` modules, so the library returns an `Either` and no test exits early.
  The kind of an IO error comes from `System.IO.Error`, such as `isResourceVanishedError`.
  `decodeUtf8` and `strictDecode` are banned like the partial functions: they throw on invalid
  input. `throw` and `assert` are banned like `error`; `throwIO` stays allowed.
- `scripts/check` clears every `HSPEC_*` variable and passes `--ignore-dot-hspec`, because either
  can skip tests or turn every test into a dry run.
- QuickCheck runs with a fixed seed, so the gate never fails by chance. The weekly
  `scheduled.yml` job tries random seeds and lists newer dependencies. It never blocks a merge
  and opens no issue: the owner looks at red runs.
- The `.cabal` file keeps an explicit module list, without cabal-gild's module discovery. Each
  module is a choice between `exposed-modules` and `other-modules`, and the reader sees it.
- The freeze file could differ between macOS and Linux (OS-specific dependencies or flags). Today
  they agree. If they ever differ, generate the file in CI only.
- Not closed:
  - `GHCRTS` can still change how the tests run.
  - The caller's environment is trusted: `PATH` (which `perl`, `git` and `diff` run),
    `GHCUP_INSTALL_BASE_PREFIX` and `MISE_<TOOL>_VERSION`. The check clears only what a project
    file or a stray setting can set: `MISE_ENV`, the global mise config, `CABAL_CONFIG` and
    `HSPEC_*`. CI runs with a clean environment.
  - Object files from an earlier build. GHC leaves warning flags out of its recompilation check,
    so modules built once without `-Werror` (the stanza removed, built, put back) are not
    compiled again, and the local check passes. CI builds from scratch and fails. Forcing a full
    rebuild on every run would make the Stop hook slow.
  - The gate files themselves (`.hlint.yaml`, `scripts/check`, `mise.toml`, `cabal.project`, the
    common stanza). An `ignore:` line in `.hlint.yaml` turns a ban off; `default-extensions:
    CPP` or a flag in the common stanza, or a variable in `mise.toml`'s `[env]`, changes the
    build. Only the owner's review of every change guards them. CODEOWNERS adds nothing in a
    one-owner repository, because GitHub does not let the author approve their own PR.
  - Test code that runs arbitrary IO, such as reading `/proc/self/cmdline` and starting a
    process, can still write the failure report and stop the run. The bans close the ways that
    need only base and hspec.
  - Test content: a test without an assertion (`it "x" True`, `seq` instead of `shouldBe`),
    `when False`, a generator that yields one value (`forAll (pure "")`) or deleted tests pass.
    Only review catches them. Pattern hints for each form would be one more list to dodge.
  - Exceptions that are caught and dropped (`void (try ...)`, `_ <- try ...`) and exceptions
    caught as `SomeException` (HLint cannot match types).
  - Partial functions outside the ban list, such as `Text.splitOn ""` or `Text.replace ""`, and
    partial arithmetic such as `div` by zero. The list names the ones an agent reaches for in
    base, containers and text.
  - Unused exported code (no weeder: it needs HIE files and a release per GHC version).
  - `scripts/freeze` needs a local Hackage index at least as new as `index-state`; it runs
    `cabal update` first for that reason.

## Keeping the template current

- The template comes from a working project. When you improve a gate in a project made from it,
  port the change here. Then scaffold a scratch project and run its `scripts/check`.
- To bump a tool: change `template/mise.toml.tmpl`, copy it to a scratch folder as `mise.toml`,
  run `mise lock --platform linux-x64,macos-arm64` there and copy the result to
  `template/mise.lock.tmpl`. To bump GHC: change `ghc_version` in `scripts/scaffold` once HLS
  supports it.
- CI in `kgrigorev/skills` (`.github/workflows/scaffold-haskell.yml`) scaffolds a sample project
  every week, checks that `mise.lock` is current, lints the workflows and scripts, runs the
  sample's `scripts/check`, and then replays the attacks in `tests/scaffold/haskell`
  (`scripts/test-scaffold haskell`): each must fail at its step, or pass if it is good code.
  Add an attack for every hole you close.
- Shared files (the hooks, the PR template, `pr-title.yml`, `CLAUDE.md` and the end of
  `AGENTS.md`) come from `skills/scaffold/_shared`. Change them there and run
  `scripts/sync-scaffold-shared`.
- Project-specific material (domain terms, reference documents) stays out of the template.
- The template works with any set of agent skills. It names no skill and holds no convention that
  comes from one, such as a glossary file or a folder of decision records. A project adds those
  itself.
- The reader profile is an input, not fixed text. How much the comments explain depends on who
  reads the code.
