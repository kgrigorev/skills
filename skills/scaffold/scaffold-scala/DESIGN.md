# Reasons the template files cannot carry

Every other gate states its reason in a comment in its own file.

## Choices

- **Scala 3.9 LTS, not 3.10 Next.** Scala 3.10.1 with `-Wall` warns "Catching everything" (E235)
  on every enum whose cases are all singletons, so `enum Color { case Red, Green }` fails under
  `-Werror` (scala/scala3#27548, fixed but not released). Long-term support also suits a
  scaffold. Move to 3.10 only after a release with the fix, and re-run this skill's CI.
- **The standalone `scala-cli`, pinned by mise.** The `scala` command in the 3.9.0 distribution
  bundles the older Scala CLI 1.16.0. The project's Scala version comes from `project.scala`
  either way. mise's `scala-cli` backend gives checksummed `mise.lock` entries for every
  platform.
- **Scala CLI only, no sbt or Mill.** All build settings are a few lines in one file, with no
  build language to learn.
- **No Bloop server (`--server=false`) in `scripts/check` and in every command `AGENTS.md`
  lists.** Under Bloop, a warning that `-Werror` turns into an error exits 0, and the tests
  still run (VirtusLab/scala-cli#3735, open). Each run then compiles from scratch: about 4 s for
  the sample. When the issue is fixed, re-check with an unused import and drop the flag.
- **WartRemover instead of scalafix.** WartRemover runs inside the compiler, so lint costs no
  second compile, and it sees types (`Option.get`, `List.head`). `scala-cli fix` is experimental
  and crashes when compilation fails. scalafix's ExplicitResultTypes refuses Scala 3.9. The
  WartRemover plugin is built for each exact Scala version, so a Scala bump needs a matching
  WartRemover release.
- **MutableDataStructures stays on.** It matches the `var` ban and keeps agent code in one
  style. Local builders are the cost; `foldLeft` and `++` replace them.
- **Temurin 25 LTS with `--sun-misc-unsafe-memory-access=allow`.** Scala's lazy vals still use
  `sun.misc.Unsafe`, and JDK 25 warns on first use. The warning is about the Scala library. A
  later JDK will deny that access by default; remove the option (in `project.scala` and in
  `scripts/check`) once Scala stops using it.
- **The compiler options exist twice, in `project.scala` and in `scripts/check`.** The check
  fails when the two differ. This is the only way to fail on a deleted `-Werror` or wart, or an
  added `-Wconf` or `-source:3.4`. Both are gate files, so a change costs one approval.
- **The scalafmt settings exist twice too, in `.scalafmt.conf` and in `scripts/check`.** A line
  such as `project.excludePaths` would skip files from the format check and look harmless.
- **`Throw`, `SeqApply` and `SeqUpdated` are on.** They close the rest of "calls that throw on
  ordinary input" for the types WartRemover knows. Expected failures are `Either` values, so code
  never needs `throw`. WartRemover has no wart for `Map.apply` or `String.toInt`; review covers
  them.
- **`project.scala` takes only fixed line shapes.** One exact-version coordinate per line; no
  `latest.release`, ranges, `toolkit`, `repository` or `compileOnly`. Scala CLI has no lockfile,
  so determinism rests on exact direct versions and Maven Central's immutable artifacts.
- **Only `project.scala` and `src/**/*.scala` are compiled and scanned.** Scala CLI reads
  `//> using` lines from any source it compiles, so a file outside the scanned set could add
  `-Wconf`. `.java` files would bypass scalafmt, WartRemover and `-Werror`.
- **A fixed ScalaCheck seed.** The same commit always tests the same inputs.
- **`--test-framework munit.Framework --require-tests`.** A run that finds no suite fails.
  Without `--test-framework`, `--require-tests` fails on ScalaCheck's own framework, which finds
  nothing. So plain ScalaCheck `Properties` objects would never run, and the switch-off search
  bans them.
- **`scripts/check` re-runs itself through `mise exec --locked`.** Agent shells, git hooks and
  the Stop hook start without mise activated. It re-runs `$PWD/scripts/check` after its `cd`,
  so a relative call from another folder works.
- **The mise.lock check runs before mise.** `mise exec` could install a changed version and so
  hide the difference from CI, which installs from `mise.lock`.
- **`mise.toml` takes only fixed line shapes, and the check compares the running tools with it.**
  The lock check reads plain `name = "version"` lines; TOML has other forms for the same pin.
  And `mise exec --locked` only warns when a version is missing from `mise.lock`, then runs the
  machine's java. `mise.local.toml`, `.tool-versions` and `MISE_<TOOL>_VERSION` can all cause
  that, so the check tests the result (`scala-cli version`, `java -version`, `JAVA_HOME`) instead
  of listing each source.
- **No symlinks in `src/`, and file names of letters, digits, `_`, `.` and `-`.** Scala CLI
  follows links and compiles names with spaces, but the scans read only plain files and split
  the file list on spaces. Rejecting both keeps the scans complete. `scan` also fails when grep
  cannot read a file (exit 2), which would otherwise pass as "no match".
- **The check reads munit's summary line for each suite.** munit exits 0 for ignored tests and
  for a suite with no tests (it reports that suite as ignored). Tags are banned outright:
  `munit.Fail` turns a failing test into a pass, and a tag can be built from any string. Every
  tag is reached through package munit, so the ban is on `munit.<Tag>`, munit imports of a tag or
  of `*`, `munit as`, and `package munit`; plain `Ignore` or `Fail` stay free for domain code.
- **The munit and ScalaCheck words are searched for only in test-scope files, and comment-only
  lines are skipped.** Main code cannot see munit, so `def property`, `Tag(...)` or `.only` there
  is a domain name. Scala CLI puts a file in the test scope by a `test` folder or a `.test.scala`
  name; the check counts any path with `test` in it. A line that is only a comment changes
  nothing, and comments say "Ignore blank lines". Lines with code next to a comment are still
  read, and the scalafmt switches (`format: off`, `scalafmt: {`) are found in comments too.
- **`.github/workflows/deps.yml` is online and never blocks a PR.** Newer versions change by
  the day, so they stay out of `scripts/check`.
- **Actions are pinned by commit SHA**, because a tag can move. Runners are a fixed image
  (`ubuntu-24.04`), not `ubuntu-latest`, except the shared `pr-title.yml`.

## Files without comments

- `.claude/settings.json` (JSON has no comments):
  - `sandbox.filesystem.allowWrite` lists the caches. Coursier (`~/Library/Caches/Coursier` on
    macOS, `~/.cache/coursier` on Linux) holds the compiler, libraries and scalafmt. Scala CLI
    (`~/Library/Caches/ScalaCli`, `~/.cache/scalacli`) holds its local repository. mise writes
    trusted configs to `~/.local/state/mise` and installs to `~/.local/share/mise`.
    `~/Library/Application Support/ScalaCli` holds secrets and config, so it is not writable.
  - `sandbox.excludedCommands` holds `gh *`, because the macOS TLS check fails inside the
    sandbox. It only matches a plain `gh ...` call, without `cd`, a heredoc or a redirect.
  - `attribution` is empty, so commits and PRs describe the change only.
- `.githooks/pre-push` runs on push, not on commit, so small local commits stay fast.
- `.gitignore` lists editor folders. The Stop hook treats any untracked file as uncommitted work.

## Known limits

- The Linux cache paths come from the tools' documented defaults, not from a run in the
  sandbox. Running `scripts/check` inside the Claude Code sandbox is not tested yet.
- A warm run needs no network. Coursier re-checks `scala3-library_3/maven-metadata.xml` when its
  cache entry expires, but a failed check is not fatal.
- No vulnerability scan: GitHub's dependency graph and OSV-Scanner do not read `project.scala`.
- The switch-off search bans some names: `nowarn`, `unused`, `unchecked` after a dot and
  `type X = Any` everywhere; in test files also `only`, `ignore`, `fail`, `pending`, `flaky` after
  a dot, `munit.<Tag>`, `isCI`, `.tag(`, `TestOptions`, `withTags`, `def test`, `def property`
  and munit transforms. It also matches `@annotation.nowarn`, ``@`nowarn` `` and
  `{nowarn as quiet}`. Projects rename their own code. A test that compares with a domain value
  named like a munit word after a dot (`Status.fail`) must use another name.
- Universal equality is closed for the top types (`Any`, `AnyRef`, `AnyVal`, `Matchable`,
  `Object`) and aliases to them. A given such as `CanEqual[Product, Product]` still widens `==`;
  review catches it.
- Not gated, left to review (`CODING_STANDARDS.md` names each): `Map.apply`, `String.toInt`, a
  `match` without `case _` on a type that is not sealed, `catch case _` and `case _: Throwable`,
  `val _ =` on an `Either`, `Try(...).foreach`, unused public parameters, the order of
  initialisation in an object (`-Wsafe-init` misses it too), tests without assertions, trivially
  true properties, deleted tests, and tests registered inside an `if`. A new `dep` line passes
  the check; the owner approves it in review.

## Keeping the template current

- The template comes from a working project. When you improve a gate in a project made from it,
  port the change here. Then scaffold a scratch project and run its `scripts/check`.
- CI in `kgrigorev/skills` does the same in `.github/workflows/scaffold-scala.yml`. Keep its mise
  version equal to the one in `template/.github/workflows/ci.yml.tmpl`.
- To bump a version: Scala and WartRemover together in `project.scala.tmpl`; the JDK and Scala
  CLI in `mise.toml.tmpl` (the scaffold writes `mise.lock`; keep the JDK a `temurin-` pin, which
  the check compares with `java -version`); scalafmt in `.scalafmt.conf.tmpl` and
  `scripts/check.tmpl`; action SHAs in both workflow templates and in this skill's CI.
- Shared files (`scaffold-lib.sh`, the hooks, `pr-title.yml`, `CLAUDE.md`, the end of
  `AGENTS.md`) come from `skills/scaffold/_shared`. Edit them there and run
  `scripts/sync-scaffold-shared`.
- Project-specific material (domain terms, reference documents) stays out of the template.
- The template works with any set of agent skills. It names no skill and holds no convention that
  comes from one.
- The reader profile is an input, not fixed text. How much the comments explain depends on who
  reads the code.
