# Designing scaffold gates

Read this before you add or change a gate in a `scaffold-<stack>` skill, and when you review one.
It holds what the attack rounds on the stacks taught. The first rounds attacked each template;
later rounds re-attacked the last round's fixes on a freshly rendered project.

## What the gates are for

A check cannot guard its own files. The gates catch mistakes and the cheap ways to make a red
check green: a suppression comment, a flag, a fake summary. They cannot stop an agent that is free
to edit the gate files and the tests and sets out to defeat them. The owner reviews every change to
those files, and each stack lists them as not closed. CODEOWNERS adds nothing in a one-owner
repository. So a rule below that fails against a determined attacker is not a reason to keep adding
patterns.

## Rules

- **Gate on evidence the code under test cannot write.** Scala searches the code its compiler
  printed (`-Vprint:typer`), so aliases, renamed imports and line breaks cannot hide a
  switch-off. C reads `unity.c`'s own line coverage instead of the summary a test prints. Where
  the code under test can reach the evidence, also block the ways it reaches it, and list the rest
  as open. Haskell's hspec failure report counts because HLint bans the base and hspec ways a test
  finds the report path; a test that does arbitrary IO can still forge it.
- **Search what a tool produced, not the source text.** Searches of the source fell to a new
  spelling each round: Unicode that the search reads differently from the compiler, quoted names,
  line breaks, aliases, ordinary-looking `.cabal` edits. A lexer that drops comments and strings
  first (Rust, Haskell, C++) closed many of them, but not all. So a search of the source, lexed or
  not, is a backstop beside a check of a tool's output. It is the gate only for what no tool
  reports, such as a comment that switches a formatter off; say why in the stack's `DESIGN.md`.
- **Allow what is known, don't deny what is bad.** A list of bad flags, keys or variables always
  misses one, such as Rust's `CARGO_ALIAS_CLIPPY=check`. Rust checks its settings files against an
  allow-list, and Go keeps `allowed_hidden` and `allowed_foreign`.
- **Narrow the input to shapes the check reads exactly.** Haskell names must be ASCII, Scala
  requires fixed line shapes in `project.scala` and `mise.toml`, and Rust requires plain TOML with
  no escapes or quoted keys. A rejected odd spelling costs less than a parser that almost matches
  the tool's.
- **Clear the caller's environment.** Tools read settings from variables the check did not set:
  C runs its tools under `env -i`, Rust drops the `CARGO_*` variables, Go sets `GOENV=off`,
  Haskell clears `HSPEC_*`, Python clears `PYTEST_ADDOPTS`.
- **Prove the gate saw every input; an exit status alone is not enough.** `scalafmt --check` exits
  0 on a file it cannot parse, munit exits 0 for ignored suites, and ctest counts a disabled test
  as passed, so C compares the tests that ran with `ctest -N`. Go requires every file git sees to
  be in `go list`.
- **Pin gate settings to their exact content in the check** when they sit in a file agents also
  edit for other reasons, or when a change to them looks harmless. Scala keeps its compiler options
  and its scalafmt settings in `scripts/check` too, and fails when they differ. Pinning does not
  stop an edit; it moves the edit into `scripts/check`, where review sees it. Hashing a whole gate
  file only moves the edit to the hash, so Go, Python and C++ leave their gate files to the owner's
  review. C++ also tried rules for its CMake files over three rounds, the last including a trace of
  every command CMake ran, and each round found new bypasses.
- **Each fix comes with two cases:** an attack case that the old check let through and the new one
  fails at the step its `# expect: red` line names, and a green case of ordinary code the fix must
  still accept. A wrong rejection is a regression too: first-round fixes rejected
  `proptest!(move |..|)` in Rust and broke linking against libm in C.
- **Each fix round gets a fresh reviewer.** It sees the diff and the requirements, not the earlier
  findings, and attacks a freshly rendered project. Second rounds found regressions in first-round
  fixes in Rust, TypeScript and C.
- **Stop when a round finds only new spellings of a hole already known.** Add it, with why, to the
  stack's list of open holes in its `DESIGN.md` instead of adding one more pattern. The list is
  "Not closed" in most stacks, "Not checked, and why" in C, "Known limits" in Scala and "Holes
  that stay open" in TypeScript.
- **A gate's tool gives the same verdict on the same input, on every OS the check runs on.** Never
  re-run an unexplained red gate until it turns green. Stress the tool on the CI OS until the cause
  is known, and check each run's result against the known answer, meaning which files it
  reported, not only whether it exited 0. A tool that can pass bad input now and then is unfit even
  when a re-run hides its failures: see scalafmt's native binary in `scaffold-scala/DESIGN.md`. C
  dropped its compile-flag allow-list because CMake writes the flags differently on Linux and
  macOS.
