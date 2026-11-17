# Reasons the template files cannot carry

Every other gate states its reason in a comment in its own file.

## Files

- `.claude/settings.json` (JSON has no comments):
  - `sandbox.filesystem.allowWrite` lets `scripts/check` run inside the sandbox without a
    bypass. `~/.cargo` holds the crate cache and cargo's lock files at its root, so the whole
    folder is listed, not only `registry/`. `~/.rustup` receives the toolchain on first use.
    mise writes installs to `~/.local/share/mise`, trusted-config records to
    `~/.local/state/mise`, and downloads to its cache: `~/Library/Caches/mise` on macOS,
    `~/.cache/mise` on Linux. Both are listed, so one file serves both systems. With
    `XDG_CACHE_HOME` set, the owner adds that path. A warm run writes to none of them.
  - `sandbox.excludedCommands` holds `gh *`, because the macOS TLS check fails inside the
    sandbox. It only matches a plain `gh ...` call, without `cd`, a heredoc or a redirect.
  - `attribution` is empty, so commits and PRs describe the change only.
- `.githooks/pre-push` runs on push, not on commit, so small local commits stay fast.
- `.gitignore` lists `.idea/`. The Stop hook treats any untracked file as uncommitted work.
- `rustfmt.toml` holds comments only. Without it, rustfmt reads a `rustfmt.toml` in a folder
  above the project or in the user's config folder, so `disable_all_formatting` there turned the
  format check green on misformatted code. `cargo fmt` takes style edition 2024 from the edition,
  and every stable option worth setting repeats a Clippy style lint. `scripts/check` rejects a
  setting in the file and any other `rustfmt.toml` or `.rustfmt.toml` in the project.
- No `.cargo/config.toml` in the project: it can alias `clippy` to `check`, add rustflags or set
  `[env]`. `scripts/check` rejects it.
- No Brewfile: mise installs every tool. The README asks for `brew install mise gh`.

## Tools

- `rust-toolchain.toml` is the one Rust pin. rustup, rust-analyzer and editors read it, and it
  pins rustfmt and Clippy with the compiler. A `rust` line in `mise.toml` would be a second
  copy. Worse, mise passes its own Rust version to rustup in `RUSTUP_TOOLCHAIN`, which rustup
  ranks above the file, so a global `rust = "stable"` would win. The setting
  `idiomatic_version_file_enable_tools = ["rust"]` makes mise read the file instead.
- mise pins the cargo plugins as release binaries with checksums. `cargo install` builds from
  source, slowly, and does not pin the plugins' own dependencies.
- CI uses `jdx/mise-action`, which reads the same files. `dtolnay/rust-toolchain` takes the
  version as an input, a second copy of the pin.
- `scripts/check` re-runs itself under `mise exec` (30-50 ms), so every runner gets the pinned
  tools without a prefix: an agent shell, the hooks, CI and a person.

## scripts/check

- Warnings become errors through `CARGO_BUILD_WARNINGS=deny`, not `RUSTFLAGS=-D warnings`.
  RUSTFLAGS is part of cargo's build cache key, so every switch between a plain `cargo build`
  and the check would rebuild all dependencies. `build.warnings` is stable since Cargo 1.97 and
  applies to the packages in this repository, path dependencies too, not to crates.io crates.
- The check drops every `CARGO_*`, `RUSTC*`, `RUSTDOC*`, `CLIPPY_*`, `PROPTEST_*` and
  `NEXTEST_*` variable, except where files go, proxies and terminal output. A list of bad
  variables would always miss one, such as `CARGO_ALIAS_CLIPPY=check`, which turned the check
  green with an `.unwrap()` in the library.
- It sets `CARGO_ENCODED_RUSTFLAGS=''`. Cargo uses the first rustflags source that is set, so
  the empty value also wins over rustflags in any config file. `--config 'build.rustflags=[]'`
  does not work: cargo merges arrays.
- It calls `cargo-clippy clippy`, not `cargo clippy`, so an alias cannot replace a plugin.
  Built-in commands such as `build` and `test` cannot be aliased.
- `cargo fetch --locked` runs once and every later step runs `--frozen`. cargo-deny and
  cargo-shear need the crates of every platform in `Cargo.lock`; Clippy downloads only the
  host's. On a warm machine the fetch takes 0.02 s and needs no network.
- Cargo config outside the project: the check rejects only what no command-line flag can undo:
  `[env]`, `[profile]`, `[unstable]`, a replaced compiler, rustdoc or wrapper, a test `runner`
  and `build.target`. It names the file, line and section. Aliases, linkers and network
  settings pass, so a common `~/.cargo/config.toml` keeps working. `cargo config get` would be
  exact but is nightly-only. Costs: a developer must move such settings out of a global config
  or set `CARGO_HOME`; global rustflags (for example a faster linker) give `target/` two cache
  states; `RUSTC_WRAPPER=sccache` is dropped. The match reads lines with quotes dropped, so it
  sees quoted keys and keys inside a one-line inline table (`env = { ... }`), and it rejects
  `\u` escapes. A multi-line inline table (TOML 1.1) would slip past; CI has no such file.
- Settings files in the project are checked against an allow-list, not a list of bad keys.
  Each bad-key list the first version had was beaten: an escaped key (`"overflow\u002dchecks"`),
  a quoted table (`["workspace"]`), a nextest wrapper script that ran `true` instead of the
  tests, `autotests = false` with a `[[test]]` that never runs, a `build.rs` that sets a cfg.
  `Cargo.toml` may hold `[package]` metadata keys, the two dependency tables, `[features]` and
  `[lints]`; `.config/nextest.toml` two profiles with timeout and output keys. Both must be
  plain TOML: no escapes, no multi-line strings, no quoted keys, so a key reads as itself. The
  scan is a small Perl script; Perl ships with macOS and the Ubuntu runners, and no pinned TOML
  tool is needed.
- `cargo metadata` must list one local package. A path dependency or a workspace member is a
  crate outside `[lints]`: one with `unsafe` and `.unwrap()` passed every other gate.
- mise reads `.mise.toml`, `.config/mise.toml`, `.tool-versions` and more. One with
  `[env] _.path` put a fake `cargo-clippy` first on PATH. The check asks `mise config ls` for
  the files in use, before `mise exec` runs any tool, and allows only `mise.toml` and
  `rust-toolchain.toml` from the project. Config in folders above the project and the user's
  global mise config still apply locally; CI has neither.
- The dependency step sits right after lint. It is a lint on the dependency graph, and it reads
  only `Cargo.lock` and crate manifests, so it is fast and the same every day. The RustSec
  advisory check needs a database that changes daily, so `scheduled.yml` runs it.
- nextest runs the tests: a hung test fails after 60 s, each test runs in its own process, and
  an empty run fails. It cannot run doc examples, so `cargo test --doc` follows.
- Every `#[test]` function name in the code must be in `cargo nextest list`. This catches any
  cfg that is never true (`not(all())`, `miri`, a cfg only a build script sets) without a list
  of bad cfgs, and any test target cargo skips. It compares names, not counts, so a test written
  as `#[core::prelude::v1::test]` cannot make up for a hidden one. A test that a macro writes is
  not matched and not checked; macros need the owner's approval.
- `--run-ignored all` runs `#[ignore]` tests too, so `#[ignore]` cannot hide a red test.
- `PROPTEST_RNG_SEED=1` makes every run try the same cases. The weekly `explore` job in
  `scheduled.yml` tries new random cases, 10 000 per property.
- `rust-version` equals the pinned Rust, so building with the pin is the MSRV check.

## Lints

- `#[allow]` and `#[expect]` are rejected, even with a reason. A reason string is free text an
  agent can always write, and the gate must not depend on agent judgement. The owner adds a
  crate-wide exception in `Cargo.toml` `[lints]` instead.
- Left out on purpose: `indexing_slicing` (flags every fixed index and slice; noisy), the
  `nursery` group (unstable, false positives), the `cargo` group (metadata lints, useless for a
  private crate), `unused_crate_dependencies` (fires on every library dependency in the binary
  target; Cargo's own `unused_dependencies` lint and cargo-shear do this job),
  `missing_docs_in_private_items` (forces a doc comment on
  every test), `print_stdout` (fires on the `main.rs` that must print).
- The suppression search reads each `.rs` file whole, so an attribute that rustfmt splits over
  lines matches too. It rejects any attribute that holds a `$`: a `macro_rules!` could build
  `#[allow]` from an `allow` token at the call site. This also rejects the common
  `$(#[$meta])*` pattern; macros need the owner's approval anyway. `unsafe_code = "forbid"`
  holds regardless. Deleting a line from `[lints]` is a gate-file change that review catches.
- Doc examples marked `ignore`, `no_run` or `should_panic` are rejected: each lets a wrong
  assertion pass. `compile_fail` stays allowed, because it shows what the types forbid. The
  match takes any rustdoc separator, so `rust ignore` is caught too.
- proptest settings in the code (`proptest_config`, `ProptestConfig`, `TestRunner`) are
  rejected: `with_cases(0)` passed a wrong property, and a fixed case count overrides the
  weekly job's `PROPTEST_CASES`.
- A thrown-away Result: `let _ =` is a lint, `.ok();` is the `unused_result_ok` lint, and
  `_ = f();` is rejected by the search. `drop(f())`, `if let Ok(_)` and other forms pass;
  review catches them.
- `#[doc(hidden)]` is rejected: it takes a public item out of `missing_docs`.
- `std::process::abort` is a disallowed method in `clippy.toml`. `assert!` in library code and
  indexing (`b[0]`) still panic on bad input. `indexing_slicing` is left out (see above), and
  `assert!` states an invariant: a failing one is a bug, which a panic is for.
- Left to review: a deleted test, a test without an assertion, an early `return` on an
  environment variable, `#[should_panic(expected = ...)]` that matches the wrong panic, and an
  unused `pub` item (never dead code in a library).

## CI

- The title job lives in `pr-title.yml`, apart from `ci.yml`. With the `edited` trigger in
  `ci.yml`, a title edit would start a new check run, and the concurrency group would cancel the
  running one.
- The Rust toolchain is not cached in CI: about 20 s per run. rust-cache does not cache
  toolchains.
- The licenses allowed in `deny.toml` are the common permissive ones. MPL-2.0 and others need the
  owner's approval.

## Keeping the template current

- The template comes from a working project. When you improve a gate in a project made from it,
  port the change here. Then scaffold a scratch project and run its `scripts/check`.
- `scripts/scaffold` asks mise for releases at least a day old (`--minimum-release-age 1d`). A
  release younger than that may still get a quick fix, or miss from the mise registries.
- CI in `kgrigorev/skills` does the same in `.github/workflows/scaffold-rust.yml`, weekly too,
  so a new Clippy lint that fires on the stub shows up there first. It pins the tool versions at
  the top of that file. When you scaffold with newer tools, bump them there to match.
- Project-specific material (domain terms, reference documents) stays out of the template.
- The template works with any set of agent skills. It names no skill and holds no convention that
  comes from one, such as a glossary file or a folder of decision records. A project adds those
  itself.
- The reader profile is an input, not fixed text. How much the comments explain depends on who
  reads the code.
