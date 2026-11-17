# Reasons the template files cannot carry

Every other gate states its reason in a comment in its own file.

- `.claude/settings.json` (JSON has no comments):
  - `sandbox.filesystem.allowWrite` lists mise's install, state and cache folders, so
    `scripts/check` runs inside the sandbox without a bypass. The cache is
    `~/Library/Caches/mise` on macOS and `~/.cache/mise` on Linux, so both are listed. `build/`
    is inside the project and needs no entry.
  - `sandbox.excludedCommands` holds `gh *`, because the macOS TLS check fails inside the
    sandbox. It only matches a plain `gh ...` call, without `cd`, a heredoc or a redirect.
  - `attribution` is empty, so commits and PRs describe the change only.
- `CMakePresets.json` (JSON has no comments):
  - The sanitizer flags go in `CMAKE_CXX_FLAGS`, not in `cmake/strict.cmake`, so GoogleTest and
    rapidcheck are built with them too. Mixed builds give false container-overflow reports.
  - Both hardening macros are set: macOS uses libc++ (`_LIBCPP_HARDENING_MODE`) and Linux uses
    libstdc++ (`_GLIBCXX_ASSERTIONS`). Each library ignores the other's macro.
  - `CMAKE_OSX_DEPLOYMENT_TARGET` fixes the target triple. Without it the triple follows the
    installed macOS SDK, and availability checks change between machines. Linux ignores it.
  - `RC_PARAMS=seed=1` makes property tests try the same inputs on every run of a commit.
  - `GTEST_FAIL_IF_NO_TEST_LINKED` and `GTEST_FAIL_IF_NO_TEST_SELECTED` make a test binary
    without tests, or a filter that selects none, fail. `noTestsAction: error` does the same for
    ctest.
  - There is one preset, `dev`, which `scripts/check` builds. No release preset: it would not be
    a gate.
- `.githooks/pre-push` runs on push, not on commit, so small local commits stay fast.
- `.gitignore` lists `.idea/` and `.cache/` (the clangd index). The Stop hook treats any
  untracked file as uncommitted work.

## What `scripts/check` reads after the configure step

- Grepping CMake files for flags misses most ways to pass one: a response file (`@file`), a
  joined `-isystem<dir>`, `string(REPLACE ...)` on `CMAKE_CXX_FLAGS`, `-U`, a cleared
  `COMPILE_OPTIONS`. So the check reads what the compiler gets in `compile_commands.json`: every
  flag must be on a short list, and the `-W` flags of `cmake/strict.cmake` plus the sanitizer and
  hardening flags must be there. The list is closed on purpose; a new flag is an owner decision.
  The required sanitizer and hardening flags are written into the check, not read from
  `CMakePresets.json`, because a preset edit is the easiest way to drop them.
- `ninja -t deps` lists every file the compiler read. The check requires that set, inside the
  project, to equal the `.cpp` and `.hpp` files the other gates read. This closes `#include` of
  any other extension, untracked or ignored headers, and files that nothing compiles (never
  linted, never tested).
- `ctest --show-only=json-v1` lists every test with its properties. Each test must be one
  GoogleTest case as `gtest_discover_tests` writes it, with no other property, and the preset
  must run all of them. Properties such as `PASS_REGULAR_EXPRESSION` or `ENVIRONMENT` can be set
  in many CMake spellings; reading the result covers all of them.
- Link lines in `build.ninja` may not name `-l`, `-L`, frameworks or absolute paths, except the
  C library parts `-lpthread`, `-ldl`, `-lm`, `-lrt` and `-pthread`. That catches `find_package`
  and bare system libraries, which build on one machine and not on another.
- Not enforced, left to review: edits to the gate files themselves (`.clang-tidy` checks,
  `cmake/strict.cmake`, the preset's environment), tests without assertions or deleted tests,
  and code under `#ifdef` of a macro that nothing defines. The owner reviews every PR; a CI
  label gate for gate files would add a step to each legitimate change and still trust whoever
  sets the label.

## Toolchain

- clang, clang-tidy, clangd and clang-format come from one LLVM release on conda-forge, through
  mise's `conda:` backend. Rejected: Apple clang and Ubuntu's packages (not pinnable),
  apt.llvm.org (old builds disappear), Homebrew `llvm` (one version at a time), LLVM's release
  tarballs (about 1 GB per platform), PyPI wheels (no compiler, and clang-tidy lags). clang-tidy
  must see the compiler's own headers, so all four tools come from one source.
- conda-forge ships its own standard library: libc++ on macOS, GCC's libstdc++ with a glibc
  2.28 sysroot on Linux. So a commit can build on one OS and fail on the other, and
  LeakSanitizer runs only on Linux. The owner chose libstdc++ on Linux. The project's CI runs
  Linux; the git hook and the Stop hook cover macOS.
- `scripts/check` trusts the project's `mise.toml` for its own run
  (`MISE_TRUSTED_CONFIG_PATHS`). Running the script already runs the project's code, so this
  adds no risk, and a new git worktree works without `mise trust`.
- `scripts/check` makes mise read only the project's `mise.toml`
  (`MISE_OVERRIDE_CONFIG_FILENAMES`, `MISE_CEILING_PATHS`, and a global and system config path
  that does not exist; `/dev/null` is rejected by mise). Otherwise `mise.local.toml`, a parent
  folder's config (a git worktree inside the main checkout has one) or the user's global config
  can change PATH or a version. `mise.toml` may hold only `[tools]` and `lockfile = true`, and
  each tool must resolve inside its `mise where` folder.
- `scripts/check` compares `mise.toml` with `mise.lock` before it calls mise. `mise exec
  --locked` only warns about a version that the lock lacks, then may install it and rewrite
  `mise.lock`.
- A changed checksum in `mise.lock` is not caught for a tool that is already installed: mise
  checks checksums on download. CI installs from scratch, so it catches it there.
- clang-tidy runs as its own step over `compile_commands.json`, not through CMake's
  `CXX_CLANG_TIDY`. CMake drops the compiler path from the command it gives clang-tidy, which then
  reads the macOS SDK's libc++ instead of the pinned one. The cost: clang-tidy reads every `.cpp`
  on every run.
- GoogleTest and rapidcheck come through `FetchContent` with URL and SHA-256, not a package
  manager: two test-only libraries do not justify vcpkg or Conan. rapidcheck publishes no
  releases, so the pin is a commit. Each git worktree downloads and builds them once (about
  20 s).
- C++23, not C++26: clang and libc++ do not ship reflection or contracts yet.

## Keeping the template current

- The versions live at the top of `scripts/scaffold`. Pin a version only when it is the latest
  stable release and at least two days old. Bump `MISE_VERSION` in
  `.github/workflows/scaffold-cpp.yml` together with `mise_version`.
- The scaffold writes `mise.lock` on each run, from conda-forge's current builds of the pinned
  versions. Two renders on the same day give the same files. A new conda-forge build of the same
  version changes the lock.
- CI in `kgrigorev/skills` renders the template and runs the project's `scripts/check` on
  `ubuntu-24.04` and `macos-26` in `.github/workflows/scaffold-cpp.yml`, every week and on every
  change. This is the only place the template runs on both platforms.
- The template comes from a working project. When you improve a gate in a project made from it,
  port the change here. Then scaffold a scratch project and run its `scripts/check`.
- Project-specific material (domain terms, reference documents) stays out of the template.
- The template works with any set of agent skills. It names no skill and holds no convention that
  comes from one, such as a glossary file or a folder of decision records. A project adds those
  itself.
- The reader profile is an input, not fixed text. How much the comments explain depends on who
  reads the code.
