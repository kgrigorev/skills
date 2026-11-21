# Designing scaffold gates

Read this before you add or change a gate in a `scaffold-<stack>` skill, and when you review one.
It holds what the attack rounds on every stack taught. Each round re-attacked the last round's
fixes on a freshly rendered project.

## Rules

- **Gate on evidence the code under test cannot write.** Scala searches the code its compiler
  printed (`-Vprint:typer`), so aliases, renamed imports and line breaks cannot hide a
  switch-off. C reads `unity.c`'s own line coverage instead of the summary a test prints. Evidence
  the code can write needs more: Haskell's hspec failure report proves the run finished only
  because name bans stop a test from writing the report itself. Searches of the source fell to a
  new spelling each round: Unicode lookalikes, quoted names, line breaks, aliases,
  ordinary-looking `.cabal` edits.
- **Keep a text search only as a backstop** beside a structural check, or for things that exist
  only as text, such as a comment that switches a formatter off.
- **Pin config that steers the gates to its exact content in the check**, as Scala does for
  `.scalafmt.conf` and its compiler options. Where exact content is too strict, the owner reviews
  each change. C++ tried rules for CMake files over three rounds, a trace of every CMake command
  included, and each round found new bypasses; its CMake files are now owner-reviewed.
- **Each fix comes with two cases:** an attack case that the old check let through and the new one
  rejects at the step it names, and a green case of ordinary code the fix must still accept. A
  wrong rejection is a regression too: one round's fixes rejected `proptest!(move |..|)` in Rust
  and broke linking against libm in C.
- **Each fix round gets a fresh reviewer.** It sees the diff and the requirements, not the earlier
  findings, and attacks a freshly rendered project. Second rounds found regressions in first-round
  fixes in TypeScript and C.
- **Stop when a round finds only new spellings of a hole already known.** Add it, with why, to the
  stack's list of open holes in its `DESIGN.md` (titled "Not closed" in most stacks) instead of
  adding one more pattern.
- **A gate's tool gives the same verdict on the same input.** Before trusting a new tool, run it
  thousands of times on a Linux runner over a project of realistic size, and compare each run's
  verdict, not only its exit code. A tool that can pass bad input now and then is unfit even when
  a re-run hides its failures: scalafmt's native binary failed once in about 6,000 runs over 300
  files and could pass unformatted code (see `scaffold-scala/DESIGN.md`).
