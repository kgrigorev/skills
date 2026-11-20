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
  - `-c` takes no argument; only the source file after it is skipped, so `-c @flags.rsp` is a
    response file like any other.
  - `-resource-dir` must be the pinned compiler's own, once. That folder holds the builtin
    headers and the default sanitizer ignore lists (`share/ubsan_ignorelist.txt`).
  - `-W<name>=0` is rejected like `-Wno-<name>`.
- Only GoogleTest and rapidcheck are trusted under `build/`. They are known by target (the
  objects of `gtest`, `gtest_main` and `rapidcheck`, from sources under
  `build/dev/_deps/{googletest,rapidcheck}-src/`), not by folder: a project target can write its
  output into any folder, but cannot take one of those target names. Their compile commands get
  the sanitizer and hardening flags and otherwise only their own kinds of flag (warnings, a
  standard, `-DGTEST_HAS_PTHREAD`, headers from their own sources): no `-include`, response file
  or other macro, so a project option given to them (`target_compile_options(gtest ...)`, an
  `add_compile_options` before the dependencies) cannot change their code. Their objects may
  read only their own sources, and project objects outside `tests/` may not read them at all,
  however the header gets there. Any other file the compiler reads under `build/`, `-I` into
  `build/` and `-isystem` anywhere else fail. A generated header is code that no gate read. A
  project folder named `_deps` is rejected, since `.clang-tidy` skips that path.
- `rules.ninja` may hold only the C++ rules and CMake's own (custom command, re-run, clean,
  help): a C rule (`LINKER_LANGUAGE C`) would link with no check reading it. The C++ rules must
  run the pinned tools as CMake writes them: the compile rule and the executable link rule
  exactly, the static library rule step by step (`rm`, `ar qc`, `ranlib`, and the `touch` CMake
  adds on macOS). `CMAKE_AR` and `CMAKE_RANLIB` must be the pinned LLVM tools, and
  `CMAKE_MAKE_PROGRAM` the pinned ninja, which the check passes on each configure. No target may
  set a launcher, a code check (`CXX_INCLUDE_WHAT_YOU_USE`, `CXX_CPPCHECK`, ..., which run any
  program on each compile) or a pre-link or post-build step. This closes rule variables such as
  `CMAKE_CXX_ARCHIVE_FINISH` without listing them. Shared libraries and C++ modules are not
  used, so their rules fail.
- `build.ninja` is read as a graph: an executable or a static library is made only from objects
  a checked compile step makes, an executable links only archives built here, a static library
  gets no extra archiver arguments (`STATIC_LIBRARY_OPTIONS`), and every compiled object is in
  `compile_commands.json` (`EXPORT_COMPILE_COMMANDS OFF` would hide one from the flag check).
  An executable's link step also gets its folder's compile flags, which no compile command
  shows when it links only an object library, so they must come from the short list every
  compile gets. Every executable is in the default build: one left out (`EXCLUDE_FROM_ALL`) would
  keep an old binary. Prebuilt `.o`, `.a`, `.so`, `.dylib` and similar files in the project are
  rejected.
- Each run starts from an empty CMake cache. A value that a CMake line once forced into it (a
  launcher, `CMAKE_PROJECT_INCLUDE`, a build tool) would otherwise outlive the line, locally and
  in a CI build cache. The downloaded dependencies and the compiled objects stay, so this costs
  a second or two.
- CMake files may call only the commands on a list in the check (the usual project, target,
  test, `FetchContent` and control-flow commands, `install`, read-only `file()` modes) and the
  functions and macros the project defines, whose bodies the scan reads; a function named like
  a CMake command does not count. Anything else can run a program or write a file when CMake or
  the build runs (`execute_process`, `add_custom_command`, `configure_file`, `write_file`,
  `cmake_language`, a module function such as `configure_package_config_file`), after the
  source searches, and so change or add code. A list of what to reject would miss the next
  spelling. `include` takes a module from a short list or a tracked project `.cmake` file, and
  `add_subdirectory` a project folder (with `EXCLUDE_FROM_ALL` or `SYSTEM` at most), named
  literally: CMake splits an unquoted `;` into more arguments and a variable can hold anything.
  The gate files `cmake/strict.cmake` and `cmake/toolchain.cmake` may use any command; the
  owner reviews those.
- That scan reads CMake files as written, but CMake builds commands and file names while it runs
  (`CMAKE_PROJECT_INCLUDE` makes `project()` run any file, a function can be defined after a
  call). So the configure step also writes a trace of every command CMake ran
  (`--trace-format=json-v1`), and the check reads it: each command must come from a tracked
  project CMake file, CMake's own modules, the files CMake writes into `build/dev/CMakeFiles`, or
  GoogleTest and rapidcheck; a command from a project file must pass the same list, enable no
  language but C++ (`project(... LANGUAGES CXX)`), and leave the GoogleTest and rapidcheck targets
  alone. The trace shows a list variable as one argument, so the check splits it on `;` as CMake
  does. Commands that make CMake run something take only safe arguments: `find_package` only
  `Threads` (a Find module may run a program a project variable names, such as `GIT_EXECUTABLE`),
  `FetchContent_Declare` only GoogleTest and rapidcheck by URL and SHA-256 (a `PATCH_COMMAND` in a
  list variable would run a script), and `gtest_discover_tests` only the target and
  `DISCOVERY_MODE PRE_TEST` (its arguments are written into a script that ctest runs). A new
  dependency therefore needs `scripts/check` changed too, with the owner.
- CMake runs only once, in the traced configure: `CMAKE_SUPPRESS_REGENERATION` stops ninja from
  running it again during the build (without the trace, with a filled cache), a `RERUN_CMAKE`
  rule fails, and the check fails if the build changes `build.ninja`, `rules.ninja` or
  `compile_commands.json`. The test lists that `gtest_discover_tests` writes (`*_tests.cmake`)
  are deleted before each ctest run, so a list edited in the ignored build folder does not
  outlive a revert.
- `ninja -t deps` lists every file the compiler read. The check requires that set, inside the
  project, to equal the `.cpp` and `.hpp` files the other gates read. This closes `#include` of
  any other extension, untracked or ignored headers, and files that nothing compiles (never
  linted, never tested).
- `ctest --show-only=json-v1` lists every test with its properties. Each test must be one
  GoogleTest case as `gtest_discover_tests` writes it, with no other property, and the preset
  must run all of them. Properties such as `PASS_REGULAR_EXPRESSION` or `ENVIRONMENT` can be set
  in many CMake spellings; reading the result covers all of them.
- ctest trusts a test's exit code, and what ctest runs is what discovery found. Both can be
  bent: a test can end its process with exit code 0 after a failure (a signal handler, a
  sanitizer death callback, `exec`), and discovery can be filtered (`DISCOVERY_EXTRA_ARGS`, a
  `CTestCustom.cmake` ignore list, a test executable that nothing registers). So the check asks
  each project executable that links GoogleTest for its tests (`--gtest_list_tests`, run by the
  check itself, outside the preset), runs ctest with `GTEST_OUTPUT=json`, and requires a report
  that says "completed, no failure" for every listed test. GoogleTest writes the report only when
  the test run ends normally.
  - The test executables are every program a ctest test runs, plus every project executable that
    links the archives of the `gtest` and `gtest_main` targets, found by target, not by file name.
  - ctest runs with `--repeat until-fail:1`, and a `"repeat"` key in the presets is rejected: a
    retry would hide a crash on the first run, which writes no report. A report that records a
    failure fails the check too.
  - A `CTestTestfile.cmake` may include only the scripts `gtest_discover_tests` writes next to
    it. A `TEST_INCLUDE_FILES` script runs in the real run but can see that it is not
    `--show-only` (for example by `GTEST_OUTPUT`) and set test properties only then. The check
    walks the `subdirs()` that ctest follows, from `build/dev`, so a file left by a removed folder
    does not count and no folder is skipped.
- `compile_commands.json` must give every project file the same `-D` macros, so a header cannot
  act differently in the test target than in the program.
- Link lines in `build.ninja` may not name `-l`, `-L`, frameworks or absolute paths, except the
  C library parts `-lpthread`, `-ldl`, `-lm`, `-lrt` and `-pthread`. That catches `find_package`
  and bare system libraries, which build on one machine and not on another. Link flags are a
  closed list (the sanitizer flag and the two `-Wl` flags CMake adds on macOS): `-Wl,--wrap`,
  `-Wl,--defsym` or `-Wl,-alias` could swap a function, such as a sanitizer's handler.

## What `scripts/check` reads in the source

- The C++ searches read the code with comments and the text of string and character literals
  blanked out, and with backslash-continued lines joined, as the compiler reads it. So a word
  in a comment or a string is not flagged, and a comment cannot split a word (`#/**/pragma`).
  Only the `NOLINT` and `clang-format off` searches read comments, because those are comments.
  The blanker tracks numbers as the preprocessor does, so the digit separator in `1'000` or
  `.5'0` does not open a character literal, and a dot ends a name (`x.R"(...)"` is a raw string).
- A search cannot see a word that a macro builds from parts, so token pasting (`##`) is
  rejected. Names in code must be ASCII, so a word cannot hide in other letters.
- `asm` labels are rejected: the symbol name sits in a string, which the searches do not read,
  so `__asm__("___ubsan_handle_add_overflow_abort")` could define a sanitizer's handler.
- `#if`, `#ifdef` and `#elif` may test only `__APPLE__`, `__linux__`, `__cplusplus`, `__cpp_*`
  and `__has_include` of a header named without a slash (`<print>`, `<unistd.h>`), except
  GoogleTest's and rapidcheck's. This is a closed list for the same reason as the flag list:
  code under any other macro (`NDEBUG`, `__OPTIMIZE__`, a macro nothing defines) is never
  compiled in the checked build, and naming each such macro misses the next one.
  `__has_include(<gtest/gtest.h>)` is true in test files only. `#define` and `#undef` of a
  reserved name (`__linux__`, `_LIBCPP_...`) are rejected, since they would change those answers
  for one file; the libc feature macros (`_GNU_SOURCE`, `_POSIX_C_SOURCE`, ...) are fine. Headers
  use `#pragma once`, the only allowed pragma.
- An `#include` must name its file. `#include DEBUG_HEADER` would hide from the searches which
  file it is, such as GoogleTest outside `tests/`.
- Test files are the files under `tests/`, and only they may include GoogleTest or rapidcheck
  (`<rapidcheck.h>` too). In them, `main` and a bare `return;` are rejected, in helper headers
  too, since a header can hold a `TEST`: write a guard clause there as `if`/`else`. A property
  skips an input with `RC_PRE`, which fails it when too many are skipped.
- `std::abort`, `std::terminate`, `std::quick_exit`, `_Exit` and `_exit` are rejected: they skip
  the test report and the caller's error handling. A qualified name (`std::abort`,
  `::std::abort`, `::abort`, with spaces or a comment around `::`) is rejected in any use, its
  address too. A plain `abort(...)` is rejected as a call, inside a class too (call a member
  as `this->abort()`), and inside a `#define`. A member function of the same name
  (`void abort()`, `job.abort()`, `Job::abort()`) is fine. A namespace alias of `std` is
  rejected, and so is `using namespace std;` (`using namespace std::literals;` is fine), since `sys::terminate()` would not read as `std::`. The address of a plain `abort` (`&_Exit`, `= abort;`) is rejected too. `assert` stays, for
  preconditions.
- `.clang-format-ignore` is rejected with the nested `.clang-tidy` and `.clang-format` files: it
  makes clang-format skip the files it lists. clang-format also reads one in any folder above
  the project (the main checkout around a nested worktree), so the check looks there too.
- Lines must end in LF: a CR LF file gets its own message rather than "outside ASCII".
- The dependency scan reads CMake as CMake does: it drops `#` and `#[[ ]]` comments outside
  quotes, joins a command over its lines, and matches command names in any letter case.
- In test files, clang-tidy's `bugprone-unchecked-optional-access` is off. It does not model
  `ASSERT_TRUE(value.has_value())`, so it rejects the usual GoogleTest code. Every line of a test
  runs in the check, and the hardened standard library stops a bad access there.
- `misc-include-cleaner` ignores rapidcheck's headers: it maps `rc::gen::inRange` to no header,
  so no include of `rapidcheck/gen/Numeric.h` passes.

## Not closed, left to review

The owner reviews every PR. These are the known ways past the gates, and why each stays open:

- Edits to the gate files themselves: `.clang-tidy` checks, `cmake/strict.cmake`,
  `scripts/check`, and the test preset's environment (for example `max_size=2` in `RC_PARAMS`,
  so properties try only tiny inputs). A CI label gate for gate files would add a step to each
  legitimate change and still trust whoever sets the label; hashing them would do the same.
- CMake code. CMake is a programming language, and its own modules, FetchContent and the
  scripts that ctest runs read project input in many places. Three rounds of review each found
  new ways for a short CMake change to run a program or change a test after the source
  searches, so AGENTS.md lets agents change only the list of targets in `CMakeLists.txt`, and
  the owner reviews every CMake change. The checks above (the command list, the trace, the
  build graph, the rules and the per-test reports) make such a change hard and visible, but do
  not close it.
- Tests without assertions, deleted tests, and tests whose assertions sit under a condition that
  is false. No tool can tell a weak test from a strong one.
- A swallowed error: `catch (...) { return 0; }` or `catch (const std::exception &)` with a
  default value. The catch is not empty, so `bugprone-empty-catch` is silent, and catching to
  return a fallback is sometimes right.
- A dropped result: `std::ignore = f();` or `static_cast<void>(f());` on a `[[nodiscard]]`
  function. `main` needs the second form for `std::fputs`, so the check allows both and
  CODING_STANDARDS.md asks the reviewer to look.
- Code that detects the test build without a macro: a `std::source_location` default argument
  or `__FILE__` inside a macro names the calling test file. The searches catch `__BASE_FILE__`
  only.
- A `main` for a test executable in a file outside `tests/`, or a test that writes a fake
  GoogleTest report before it ends the process.
- Code that detects the test run at run time, for example by reading `/proc/self/cmdline` or the
  program name. `std::getenv` is caught by clang-tidy's `concurrency-mt-unsafe`.
- An `#include` of an absolute path outside the project (`#include "/opt/x.hpp"`): the compiler
  and the SDK live outside it too, so the deps check skips those paths. CI does not have the
  file, so it goes red there.
- A dependency's own CMake code. FetchContent runs GoogleTest's and rapidcheck's CMake files,
  which the scan does not read; their URL and SHA-256 pin them, and a new dependency needs the
  owner.
- A file under `build/dev/_deps/*-src` changed after the download, by hand or by CMake code that
  got past the checks. CI caches `build/dev` and restores an older cache through
  `restore-keys`, so such a change could outlive the commit that made it; the owner's review of
  CMake changes is what stops the second case.

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
  each tool must resolve inside its `mise where` folder. A line above the first section is
  rejected (a dotted `env.NAME` key is an `[env]` table), and each tool line is
  `name = "version"`, so no inline table carries options. The missing config path lies in the
  git-ignored `build/`, so the check deletes it before each run.
- `scripts/check` unsets what the caller's shell could pass to the tools: `GTEST_*`, `CMAKE_*`,
  `CTEST_*`, `TESTBRIDGE_*` (GoogleTest reads `TESTBRIDGE_TEST_ONLY` as a filter), `*SAN_*`, `LD_*`,
  `DYLD_*`, the compiler flag variables, `CCC_*`
  (`CCC_OVERRIDE_OPTIONS` edits clang's command line), `COMPILER_PATH` and `GCC_EXEC_PREFIX`
  (where clang finds the linker), the include path variables and `SDKROOT`. CI has none of
  them.
- A project path with a space fails early: `compile_commands.json` quotes it, and the checks
  read commands word by word.
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
