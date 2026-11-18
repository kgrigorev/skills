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
- Unity 2.7.0 is vendored in `third_party/unity/`: `src/unity.c`, `src/unity.h`,
  `src/unity_internals.h` and `LICENSE.txt`, unchanged from
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
- The search for suppressions runs twice: on the source, for comments and conditions such as
  `NOLINT` or `#ifndef __clang_analyzer__`, and on the preprocessed project lines, where a macro
  can no longer hide a pragma or an attribute.
  Sanitizer detection is matched by its spelling (`__has_feature`, `__SANITIZE_`, `__asan_`), not by
  the word `sanitizer`, so a function such as `name_sanitizer` passes.
- The tools run with `env -i` and only `PATH`, `HOME` and `TMPDIR`. `LSAN_OPTIONS`, `CFLAGS` or
  `CMAKE_C_COMPILER_LAUNCHER` from a shell or a mise config would change a result. The check also
  fails when a tool on `PATH` is not the pinned one, or when a mise config other than `mise.toml`
  applies in the repository.
- `scripts/check` holds the sha256 of every file in `third_party/unity/`. Unity is built without
  the gates, and its summary decides whether a test passed.
- `scripts/check` rejects a raw `add_test` in `CMakeLists.txt`. The helpers in
  `cmake/gates.cmake` add the checks that Unity and libFuzzer need. A Unity test runs through
  `cmake -P cmake/gates.cmake`, which needs both exit code 0 and Unity's summary of passed tests.
  A `FAIL_REGULAR_EXPRESSION` alone passes a `main` that drops the result of `UNITY_END`, and a
  `PASS_REGULAR_EXPRESSION` makes ctest ignore the exit code, so a leak found at exit would pass.
- `scripts/check` fails when fewer tests ran than `ctest -N` lists, or when one did not run: ctest
  counts a disabled test as passed, and a preset `filter` drops tests without a word.
- Not checked: whether a test asserts anything, and edits to `.clang-tidy`, `.clang-format` or
  `scripts/check` itself. Line coverage would not prove the first, and the check cannot guard its
  own rules. The owner's review covers both, with `.github/CODEOWNERS` (step 4 of `SKILL.md`).
- Suppressions that `scripts/check` does not reject: `(void)name;` for an unused parameter. It is
  the plain C way and switches nothing off.

## CMakePresets.json (JSON has no comments)

- `dev` is what `scripts/check` runs: Debug, AddressSanitizer and UndefinedBehaviorSanitizer,
  clang-tidy. `-O1` keeps the sanitizers fast and the stack traces readable.
  `-fno-sanitize-recover=all` makes every finding stop the test.
- The test preset sets `detect_leaks=1` in `ASAN_OPTIONS` and `LSAN_OPTIONS`, because
  LeakSanitizer is off by default on macOS, and a `LSAN_OPTIONS` from a shell would turn it off.
  `noTestsAction: error` fails a run with no tests.
- `release` (`-O2`, `_FORTIFY_SOURCE=3`, stack protector) is not a gate. The weekly workflow
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
  `template/scripts/check.tmpl`.
- Project-specific material (domain terms, reference documents) stays out of the template.
- The template works with any set of agent skills. It names no skill and holds no convention that
  comes from one, such as a glossary file or a folder of decision records. A project adds those
  itself.
- The reader profile is an input, not fixed text. How much the comments explain depends on who
  reads the code.
