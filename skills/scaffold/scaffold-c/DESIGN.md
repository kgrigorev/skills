# Reasons the template files cannot carry

Every other gate states its reason in a comment in its own file.

## Toolchain

- The compiler is pinned, not only the formatter and linter. With `-Werror` the compiler is a
  linter too, and Apple clang, distro clang and GCC warn differently for the same code.
- The tools come from conda-forge through mise's `conda:` backend. It ships the exact LLVM release
  for macOS and Linux, with a Linux sysroot, binutils and the sanitizer and libFuzzer runtimes.
  `mise.lock` pins every package by URL and checksum. Rejected: the LLVM release tarballs (about
  1-2 GB per platform), PyPI wheels (formatter and linter only, compiler unpinned), Homebrew or
  apt (no exact patch version, differ per OS), `zig cc` (no AddressSanitizer).
- `mise.toml` sets `locked = true`, and `scripts/check` fails when `mise lock --dry-run` would
  change the lock. Without both, a version change in `mise.toml` installs the new tool and
  rewrites `mise.lock` quietly, or runs a tool that is already installed but not locked.
- No GCC job. The gates use clang-only warnings, and GCC would be an unpinned second compiler.
- conda's clang config file puts its own libraries (openssl, zlib, iconv, ...) on the include
  path. `scripts/check` rejects any header from there. `--no-default-config` is not the fix: on
  Linux the same file supplies the sysroot.
- clang-tidy and clangd come from the `clang-tools` package, which lacks clang's own headers and
  does not read clang's config file. `cmake/gates.cmake` puts both into every compile command.
  Without that, `#include <stdbool.h>` fails clang-tidy, and on Linux clang-tidy would read the
  runner's C library instead of the pinned one.
- On macOS the SDK comes from the Xcode Command Line Tools. A new SDK can add deprecation warnings
  locally that Linux CI does not see.
- Unity 2.7.0 is vendored in `third_party/unity/`: `unity.c`, `unity.h` and `unity_internals.h`
  (`src/` in the release) and `LICENSE.txt`, unchanged from
  `https://github.com/ThrowTheSwitch/Unity/archive/refs/tags/v2.7.0.tar.gz` (sha256
  `e84eb301ca7967831e68b1728f911e87fa2d345d8ddb64f897bc2f2ee24a321c`). Builds need no network,
  and a fresh git worktree builds offline.
- Property tests use libFuzzer, which ships with clang. Rejected: theft (unmaintained since 2020).

## Gates

- Lint runs inside the build, not as its own step before it. clang-tidy needs the compile flags
  from the build, and Ninja then lints only the files that changed. Agents run the check often.
- The gates apply by directory scope in `cmake/gates.cmake`, not per target, so a target an agent
  adds gets them too.
- `scripts/check` proves the gates from the build, not from the CMake source: every compile
  command of a project file in the default target (`ninja -t commands all`) must run clang-tidy and
  the pinned clang with the gate flags, and no flag that turns one off. CMake has too many ways
  to skip a gate for a text search to list them: any letter case, `include()`, subfolders,
  `EXCLUDE_FROM_ALL`, `SYSTEM`, source properties, presets, environment variables. The flag list
  in `scripts/check` repeats `cmake/gates.cmake` on purpose, so an edit to the gates alone turns the
  check red.
- Every file that a project file includes must be a `.h` or `.inc` file that git tracks (from
  `ninja -t deps`). The format and the searches read only those, so a `.inl` file or an ignored
  header cannot hide a suppression.
  A file from outside the repository must come through an include folder: the compiler's own
  list, or an `-I` folder that CMake declares for a dependency. `#include "../../x.h"` cannot reach
  code that no search reads and that CI does not have.
- The search for suppressions runs four times, each on what a tool made, not on text a line break
  can split:
  - on the source text, for comments and conditions such as `NOLINT` or
    `#ifndef __clang_analyzer__`.
  - on clang's raw tokens, for directives: `#line`, line markers, `#pragma`, `#define` or `#undef`
    of a Unity name or of `abort`/`exit`, `#define` of a project function name (`<prefix>_...`)
    under `test/`, and `#if` in a test file. A comment, a line splice or the digraph `%:` cannot
    hide a directive from the lexer. A name the project defines, such as `TEST_BUFFER_SIZE`,
    passes. The build check applies the same names to `-D` and `-U`.
  - on the preprocessed project lines, where a macro can no longer hide a pragma or an attribute.
    A line marker that renames the file is reported, so `#line` in any spelling cannot move lines
    out of the search.
  - on the syntax tree, with clang-query: attributes (unused, used, no_sanitize, suppress,
    no_profile_instrument_function, weak, alias, asm labels) in any spelling, a dropped result of
    any project function, `exit` or `_exit` in `src/` (called or taken as a pointer), and `main` or
    `LLVMFuzzerInitialize` in a property test.
  Sanitizer detection is matched by its spelling (`__has_feature`, `__SANITIZE_`, `__asan_`), not by
  the word `sanitizer`, so a function such as `name_sanitizer` passes. The CMake search skips
  comments, so a comment may say "tests disabled".
- The tools run with `env -i` and only `PATH`, `HOME` and `TMPDIR`. `LSAN_OPTIONS`, `CFLAGS` or
  `CMAKE_C_COMPILER_LAUNCHER` from a shell or a mise config would change a result. The check also
  fails when a tool on `PATH` is not the pinned one, or when a mise config other than `mise.toml`
  applies in the repository.
- `scripts/check` holds the sha256 of the five files in `third_party/unity/` and fails on any
  other file there, ignored by git or not. Its compile command may add no `-D`, `-U`, `-include`
  or include folder. Unity is built without the gates, its counts decide whether a test passed,
  and its folder is exempt from the searches.
- Every test must come from `add_unity_test` or `add_property_test`, with no test property but
  `WORKING_DIRECTORY`. `scripts/check` reads CMake's own list (`ctest --show-only=json-v1`, with
  the backtrace of each `add_test`), so `cmake_language(CALL ...)` with a built-up name cannot add
  `WILL_FAIL` or `ENVIRONMENT`. The CMake search for `add_test` stays for a clearer message.
  Each test's command must be the helper's own: the cmake that runs the check, `cmake/gates.cmake`,
  a source in the repository and the pinned llvm-cov and llvm-profdata. The helpers read
  `CMAKE_COMMAND` and `GATES_LLVM_COV`, which `CMakeLists.txt` could set to a program that
  always exits 0.
  The helpers add the checks that Unity and libFuzzer need. A Unity test runs through
  `cmake -P cmake/gates.cmake`, which needs exit code 0, Unity's summary of passed tests, and
  Unity's own counts: unity.c is built with line coverage, and the lines that count a run, a
  failed and an ignored test must have run at least once, never and never. The test can print any
  text (`freopen` of `stdout`, then a summary of its own), but not change those counts.
  A `FAIL_REGULAR_EXPRESSION` alone passes a `main` that drops the result of `UNITY_END`, and a
  `PASS_REGULAR_EXPRESSION` makes ctest ignore the exit code, so a leak found at exit would pass.
- Every line of a Unity test file must run (clang's source-based coverage, read with llvm-cov).
  One rule covers a test that `main` never runs (`(void)name;` keeps it from
  `-Wunused-function`), an early `return`, `TEST_ABORT`, a skip on an environment variable and a
  `main` that skips the tests to print a Unity summary. Line coverage cannot see code that is not
  compiled, so a test file has no `#if`. A partly run line counts as run, so an assertion whose
  failure branch did not run passes. `llvm-tools` is pinned on its own, because conda's clang does
  not bring it on Linux.
- A property test runs through `cmake -P cmake/gates.cmake` too, with line coverage: libFuzzer must
  have called `LLVMFuzzerTestOneInput` 100000 times. A target that exits early, or prints
  libFuzzer's `Done 100000 runs` itself, fails. Its failure branches are not measured: they never
  run. A property test defines neither `main` (which would replace libFuzzer's) nor
  `LLVMFuzzerInitialize` (which can end the run or rewrite its options).
- Tests link the project's static libraries whole (`WHOLE_ARCHIVE`). A test that defines a
  library function itself then fails with a duplicate symbol. Without it, the linker leaves the
  library's object out and the test checks the stub. So a test may link no shared library (the
  stub would win quietly), a library must be defined before the test that links it, and a library
  function may not be `weak`.
- `scripts/check` removes any `CTestCustom.*` from the build folder, in any letter case and as a
  symlink too, and fails. `CTEST_CUSTOM_TESTS_IGNORE` there drops a test from every ctest run, and
  git ignores `build/`.
- `scripts/check` fails when fewer tests ran than `ctest -N` lists, or when one did not run: ctest
  counts a disabled test as passed, and a preset `filter` drops tests without a word.
- Not checked, and why:
  - Whether a test asserts anything, or whether a property test reaches the code (a guard such as
    `if (size < 4000) return 0;` passes every input by). Coverage proves that a line ran, not that
    it checks the result. CODING_STANDARDS.md asks for both, and the owner reviews tests.
  - `abort()` on bad input in the library. Only the meaning of the condition tells a broken
    invariant from bad input. `exit` in `src/` is rejected.
  - A macro that renames another C library function in a test (for example `strcmp`). Only the
    functions that end a test (`abort`, `exit`, `_Exit`, `quick_exit`, `longjmp`) and Unity's names
    are listed. A complete list would need every name the C library declares.
  - A library that a project library links in turn (`target_link_libraries(lib PUBLIC dep)`) is
    not linked whole into the tests, so a test of `lib` could stub a function of `dep`. CMake
    rejects one library linked both whole and plain in the same link.
  - Link lines and custom commands. The build check reads compile commands only, so an object
    made by `add_custom_command`, a committed `.o` or `.a`, or a linker flag such as `--wrap`
    in `target_link_options` reaches a test unchecked. Review sees these in `CMakeLists.txt`.
  - Line coverage of files other than the test's own source: a test in a `.inc` or `.h` it
    includes, a second source added with `target_sources`, or `#if` in a test file outside
    `test/`.
  - Spellings of compile flags that the build check does not list. It rejects known ones
    (`-Wno-`, `--warn-`, `-w`, `-include`, ...), not every clang alias.
  - Edits to the gate files: `.clang-tidy` and `.clang-format` (a check turned off,
    `DisableFormat: true`), `CMakePresets.json` (`environment` in the build preset, such as
    `CCC_OVERRIDE_OPTIONS=+-w`, or in the test preset, such as `detect_leaks=0`), `mise.toml`,
    `cmake/gates.cmake` and `scripts/check` itself. The check cannot guard its own rules. These
    files change only with the owner's approval, and only the owner's review guards them.
    CODEOWNERS adds nothing for a solo owner: with "Require review from Code Owners", the owner
    cannot approve the PRs an agent opens under the owner's account.
  - Other state in the ignored build folder than `CTestCustom` files. `scripts/check` keeps
    `build/dev` between runs for speed. CI builds from a clean folder.
- Suppressions that `scripts/check` does not reject: `(void)name;` for an unused parameter. It is
  the plain C way and switches nothing off.

## CMakePresets.json (JSON has no comments)

- `dev` is what `scripts/check` runs: Debug, AddressSanitizer and UndefinedBehaviorSanitizer,
  clang-tidy. `-O1` keeps the sanitizers fast and the stack traces readable.
  `-fno-sanitize-recover=all` makes every finding stop the test.
- The test preset sets `detect_leaks=1` in `ASAN_OPTIONS` and `LSAN_OPTIONS`, because
  LeakSanitizer is off by default on macOS, and a `LSAN_OPTIONS` from a shell would turn it off.
  `noTestsAction: error` fails a run with no tests.
- `release` (CMake's Release flags `-O3 -DNDEBUG`, `_FORTIFY_SOURCE=3`, stack protector) is not a
  gate. The weekly workflow
  builds it, so a release-only break shows within a week.
- Version 6 needs CMake 3.25 or newer, which current IDEs read. `CMakeUserPresets.json` is
  ignored by git and cannot redefine `dev`: CMake rejects duplicate preset names.

## .claude/settings.json (JSON has no comments)

- `sandbox.filesystem.allowWrite` lists mise's data, state and cache folders. The cache is
  `~/Library/Caches/mise` on macOS and `~/.cache/mise` on Linux. Build output stays in `build/`.
- `sandbox.excludedCommands` holds `gh *`, because the macOS TLS check fails inside the sandbox.
  It only matches a plain `gh ...` call, without `cd`, a heredoc or a redirect.
- `attribution` is empty, so commits and PRs describe the change only.

## Other

- `scripts/check` starts itself under `mise exec`, so every runner gets the pinned tools: a shell
  without mise activated, the git hook, the Stop hook and CI.
- `.githooks/pre-push` runs on push, not on commit, so small local commits stay fast.
- `.gitignore` lists `.idea/` and `.cache/` (clangd's index). The Stop hook treats any untracked
  file as uncommitted work.
- CI runs on Linux only. Local runs are mostly macOS, and macOS runners cost 10 times more.

## Keeping the template current

- The template comes from a working project. When you improve a gate in a project made from it,
  port the change here. Then scaffold a scratch project and run its `scripts/check`.
- CI in `kgrigorev/skills` does the same on Linux and macOS in
  `.github/workflows/scaffold-c.yml`, and weekly.
- To bump a tool, change `template/mise.toml.tmpl` and the `version:` of mise in the workflows.
  The scaffold writes a new `mise.lock` from it.
- To bump Unity, replace the files in `template/third_party/unity/` and the sha256 list in
  `template/scripts/check.tmpl`. `cmake/gates.cmake` finds the lines that count tests by their
  text (`Unity.TestFailures++;` and its two siblings) and fails when one moves into two places.
- Project-specific material (domain terms, reference documents) stays out of the template.
- The template works with any set of agent skills. It names no skill and holds no convention that
  comes from one, such as a glossary file or a folder of decision records. A project adds those
  itself.
- The reader profile is an input, not fixed text. How much the comments explain depends on who
  reads the code.
