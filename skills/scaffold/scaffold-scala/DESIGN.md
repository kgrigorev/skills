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
- **scalafmt runs on the JVM, through `scala-cli run --dep`, not as `scala-cli fmt`.** That
  command downloads scalafmt's native binary, built with Scala Native. Its runtime corrupts
  memory now and then (scalameta/scalafmt#5254; scala-native#4916 and #4917 are fixed upstream,
  but no scalafmt release has the fixes yet). On `ubuntu-24.04` the binary failed about one run
  in 6,000 when formatting 300 files: a segfault, a `ClassCastException`, or a formatted file
  read as empty and reported unformatted. A file read as empty could pass unformatted too, so
  re-running after a failure would not be enough. The JVM build costs about half a second more
  per check. Go back to `scala-cli fmt` once a scalafmt release built with those fixes passes a
  long stress run on Linux.
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
- **mise may load no project file besides `mise.toml`, and the tools that run are the files mise
  installed.** mise also reads `.mise.toml`, `.config/mise.toml`, `mise.<env>.toml`,
  `.tool-versions` and more, without a trust prompt for some. One of them could put a fake
  `scala-cli` first on PATH (`[env] _.path`) that forwards `version` and `fmt` and fakes `test`.
  The check asks mise itself (`mise config ls --json`) instead of listing file names, and compares
  `command -v` with `mise which` for `scala-cli` and `java`.
- **No symlinks in `src/`, and file names of letters, digits, `_`, `.` and `-`.** Scala CLI
  follows links and compiles names with spaces, but the scans read only plain files and split
  the file list on spaces. Rejecting both keeps the scans complete. `scan` also fails when grep
  cannot read a file (exit 2), which would otherwise pass as "no match".
- **The check reads munit's summary line for each suite.** munit exits 0 for ignored tests and
  for a suite with no tests (it reports that suite as ignored). Every summary must also say
  `0 failed`, so the result never rests on the exit status alone. A test that skips itself
  (JUnit's `AssumptionViolatedException`, which needs no `assume`) shows as `==> s` while its
  suite still says `0 ignored`, so those lines fail too, and so does `Exception in thread`: an
  assertion in another thread never reaches munit. A suite that started and did not finish
  fails too. Tags are banned outright: `munit.Fail` turns a failing test into a pass, and
  a tag can be built from any string. Plain `Ignore` or `Fail` stay free for domain code.
- **The test JVM records every `System.exit` with its caller, and the last one must be the test
  runner's.** A suite that calls `sys.exit(0)`, directly or through main code, in its
  constructor or `beforeAll`, ends the run with status 0 before later suites report; munit's
  summary lines cannot show a suite that never started. The JDK logs `Runtime.exit` with a stack
  trace when the `java.lang.Runtime` logger is at debug level, so the check passes a logging
  setting with `--java-opt` (not in `project.scala`) that writes those records to a temporary
  file. `Runtime.halt` records nothing, so a missing record fails too. The record must also say
  `exit(0)`: a shutdown hook that halts with status 0 turns the runner's `exit(1)` into a
  passing run.
- **Every package is the project's namespace or below it, and code may not name `scala.build`.**
  The project's classes come first on the test classpath. A test file with
  `package scala.build.testrunner` and an object `DynamicTestRunner` replaces the test runner,
  prints a passing summary and exits from the expected caller. A suite that calls the real
  runner's `main` on one good suite also exits from that caller, before its own tests run. One
  package rule also stops stand-ins for munit, ScalaCheck and JUnit classes.
- **The switch-off search reads the compiled code, not the source text.** The build passes
  `-Vprint:typer`, so the compiler prints every file after it resolved each name. There an alias
  (`type Quiet = nowarn`, then `@Quiet`), a renamed or wildcard import (`Fail as X`,
  `import munit.*`, `import _root_.munit as m`), a selector list that scalafmt splits over lines,
  and code in a string splice on a line that starts with `//` all show up in one resolved form
  (`@nowarn`, `munit.Fail`). Comments are gone, string literals are blanked before the search,
  so words in prose never count. The printout is hidden from the log. It costs no second
  compile: the search reads the output of the build-and-test run, up to the first test result,
  and fails when a source file is missing from it. The compiler adds code of its own that the
  search skips by its fixed shape: `x$1: @unchecked` in a desugared `for`, `@uncheckedVariance`
  on default arguments, and the `try`/`catch` in enum and `@main` code. A Scala bump can change
  the printout, so re-run this skill's tests after one.
- **The munit and ScalaCheck words are banned only in test files.** Main code cannot see munit,
  so `def property`, `Tag(...)` or `.only` there is a domain name. Test files are the files Scala
  CLI puts in the test scope (a folder named `test`, a name that ends in `.test.scala`) and any
  file whose compiled code uses munit or ScalaCheck. A main file such as `LatestRelease.scala`
  ("test" inside a word) is main code.
- **Tests do not catch exceptions.** `catch`, `Try(...)`, `Using(...)`, `Using.Manager(...)` and
  `scala.util.control.Exception` in a test file are banned: a test that catches can catch the
  AssertionError of its own failed assertion, and `NonFatal` includes munit's FailException.
  munit's `intercept` and `interceptMessage` check a thrown exception instead, but only for a
  type that munit's failures do not belong to: `Throwable`, `Error`, `AssertionError`, munit's
  and JUnit's failure classes, and an alias or a type parameter bounded by one are banned.
  `recover`, `recoverWith`, `fallbackTo`, `transform`, `transformWith`, `.failed` and
  `exceptionally` are banned in tests because they turn a failed `Future` into a success; the
  printout does not show the receiver's type, so `Map.transform` in a test is banned too.
  `Future.failed(...)` as an input stays free.
- **Tests may not define a `munit.Compare`.** `assertEquals` asks a given `Compare` whether two
  values are equal, so `given munit.Compare[String, String] = (_, _) => true` makes every
  string assertion pass.
- **`require`, `assert` (Predef's, not munit's), `sys.error` and macros are banned in all code.**
  The first three throw without the `throw` keyword, which the Throw wart needs. A macro
  (`scala.quoted`) builds code that WartRemover never sees, such as a null literal.
- **Universal equality is checked on the compiled types.** A CanEqual instance whose type
  arguments name a top type (`Any`, `AnyRef`, `AnyVal`, `Matchable`, `Object`), a type alias that
  mentions one (also through other aliases or in a union such as `Int | Any`), or a type
  parameter with such an upper bound fails. That covers `given [A, B] => CanEqual[A, B]`.
- **`//>` is banned anywhere in a source line.** Scala CLI reads a directive after a byte-order
  mark, so a start-of-line pattern with `[[:space:]]` would miss it.
- **The scalafmt switches are searched for in comments**, the only place they live:
  `format: off`, the IntelliJ form `@formatter:off`, and `scalafmt: {`, in any case.
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
- The switch-off search bans some names in test files: `only`, `ignore`, `fail`, `pending`,
  `flaky`, `tag`, `transform`, `recover` and `failed` after a dot, `assume`, `isCI`, `withTags`,
  `def test` and `def property`. A test that
  compares with a domain value named like a munit word after a dot (`Status.fail`) must use
  another name. A type parameter bounded by `Any` makes every type of that name suspect in
  `CanEqual`: a class named `A` next to a `[A]` somewhere needs another name.
- The search trusts the compiler's own shapes. A variable that the code itself names `x$1` can
  hide an `@unchecked` match, and test code that finds the exit-record file through the JVM's
  logging setting could forge a record. Both are deliberate attacks that review sees.
- A given such as `CanEqual[Product, Product]` still widens `==`; review catches it.
- Gate files themselves (`scripts/check`, `project.scala`, `.scalafmt.conf`, `mise.toml`,
  `mise.lock`, the workflows) can be edited. That is not closed here by design: the owner
  approves every change to them, as `AGENTS.md` says.
- Not gated, left to review (`CODING_STANDARDS.md` names each). These need types or intent that
  neither WartRemover nor a search of the compiled code has:
  - Calls that throw on ordinary input beyond the warts: `Map.apply`, `String.toInt`, `xs(i)` on
    an `Array`, `Iterator.next()`, `String.charAt`. The printed code shows `xs.apply(0)` without
    the type of `xs`.
  - Mutable state outside `scala.collection.mutable`: `AtomicInteger`, `java.util` collections,
    `array(i) = x`. MutableDataStructures knows only the Scala collections, and the Java types
    have no end.
  - Dropped errors in main code: `catch case _`, `case _: Throwable`, `val _ =` or `(x: Unit)` on
    an `Either`, `Try(...).foreach`, `Try(...).getOrElse(default)`.
  - `sys.exit` in a library function. `@main` code may exit with a status, often through a
    helper, so the search cannot tell the two apart. An exit during the tests fails the check.
  - A catch-all in main code that a test passes its assertion to, such as
    `def attempt[A](body: => A): Option[A] = Try(body).toOption`. Main code may catch, and the
    search cannot tell which calls carry an assertion.
  - Tests that check nothing: no assertion, a trivially true property (also through
    `Gen.resize(0, ...)`), an assertion in a `Future` that the test drops, tests registered
    inside an `if` or in a loop over an empty list, deleted tests.
  - A `match` without `case _` on a type that is not sealed, unused public parameters, and the
    order of initialisation in an object (`-Wsafe-init` misses it too).
  - A new `dep` line passes the check; the owner approves it in review.

## Keeping the template current

- The template comes from a working project. When you improve a gate in a project made from it,
  port the change here. Then scaffold a scratch project and run its `scripts/check`.
- CI in `kgrigorev/skills` does the same in `.github/workflows/scaffold-scala.yml`. Keep its mise
  version equal to the one in `template/.github/workflows/ci.yml.tmpl`.
- To bump a version: Scala and WartRemover together in `project.scala.tmpl`; the JDK and Scala
  CLI in `mise.toml.tmpl` (the scaffold writes `mise.lock`; keep the JDK a `temurin-` pin, which
  the check compares with `java -version`); scalafmt in `.scalafmt.conf.tmpl` and
  `scripts/check.tmpl`, and the Scala version it is built with (`-S`) in `scripts/check.tmpl`
  and `scripts/format.tmpl`; action SHAs in both workflow templates and in this skill's CI.
- Shared files (`scaffold-lib.sh`, the hooks, `pr-title.yml`, `CLAUDE.md`, the end of
  `AGENTS.md`) come from `skills/scaffold/_shared`. Edit them there and run
  `scripts/sync-scaffold-shared`.
- Project-specific material (domain terms, reference documents) stays out of the template.
- The template works with any set of agent skills. It names no skill and holds no convention that
  comes from one.
- The reader profile is an input, not fixed text. How much the comments explain depends on who
  reads the code.
