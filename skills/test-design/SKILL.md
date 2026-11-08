---
name: test-design
description: "Test evidence: a test counts once you have seen it fail, and checks outcomes and properties. Use when writing tests, fixing a bug, adding tests to code that already works, choosing between mocks, stubs and fakes, or chasing a coverage target."
---

# Test Evidence

A test is an experiment. It is evidence only when it fails against wrong code and passes against right code. A suite that arrived green has shown that it runs, nothing more. Each rule below gathers one kind of evidence and ends on its **test**: a question you ask of the suite.

Applies to any language and test framework. When the project's coding standards set the test style, the standards win.

## See it red

- **Predict, then run.** Before each run, say what you expect: which test fails and on which assertion, or that all pass. A result you did not predict is a finding about the test or the code; resolve it before moving on.
- **A bug fix starts red.** Write the test that reproduces the report and run it against the unfixed code. It fails on the assertion that names the bug, with the wrong value the report describes. Then fix, and see it pass.
- **Test-after earns its red by sabotage.** Tests for code that already works pass on the first run, which shows nothing yet. For each behaviour a test exists to check, break the code with one small edit (flip a comparison, drop a line, return a constant), run, and see *that* test fail on *that* assertion. Revert and see green. A test that stays green under sabotage checks nothing: tighten its assertion. Coverage shows which lines ran; sabotage shows which lines are checked. A coverage target is met when the covered lines are also checked.
  **Stops where:** one sabotage per behaviour, not per line. Code with a single path and no decision (a getter, a constant) needs none.
  **Test:** for each test you added, can you name the run where it failed and the edit that made it fail?

## State the property

- **Laws hold over generated input.** When code has a law, state it as a property and let the language's property library generate the inputs: Hypothesis, fast-check, QuickCheck or Hedgehog, jqwik, proptest, FsCheck, Go's native fuzzing. Add the library as a dev dependency when the project lacks one. The shapes to look for:
  - **Round trip:** `decode(encode(x)) == x`, `parse(render(x)) == x`, write then read.
  - **Invariant:** what the operation preserves or guarantees. A sort keeps the same elements and orders each neighbouring pair; a slug holds only `[a-z0-9-]` and respects its length limit.
  - **Idempotence:** `f(f(x)) == f(x)` for normalisers, formatters, slugs, upserts.
  - **Cheap check:** verifying an answer is easier than computing it, such as the route connects the two points, or the factors multiply back.
  - **Model:** a dumb model beside the clever code. Generate sequences of operations, apply each to both (an LRU cache against a plain list, a store against a dict), and compare after every step.
- **Hire the Enterprise Developer From Hell.** Picture the laziest, most malicious implementation that passes your suite: return the empty list, hard-code the example, emit every character as a run of one. Each one that passes names a property you still lack. Properties gain strength by combination: a round trip alone admits an encoder that never merges runs.
  **Stops where:** known boundaries (a threshold, empty input, the reported bug) stay as named examples beside the properties, because examples document. Build valid inputs with a generator rather than filtering random ones; filter only rare exclusions. A property that restates the implementation's formula checks nothing; an oracle must be simpler than the code it checks.
  **Test:** which wrong implementation still passes your suite?

## Check outcomes

- **Assert on what the caller gets and what the world holds.** Arrange state, act, then assert on the return value and the state afterwards. For a dependency that stores and reads, write a Fake: a small in-memory implementation that keeps the contract, so what was saved can be read back. Assert through the Fake's reads (`repo.get(id)` holds the refunded invoice), so a refactor that reads back after writing, batches calls or caches a lookup keeps the test green.
- **A query proves itself through the data it returns.** For a dependency that answers questions (a repository read, an HTTP rate lookup), seed the Fake so it answers only the right question: the repository holds that invoice under that id, the rate source answers per base currency. The result then shows the right argument flowed through, and an implementation that asks the wrong question gets the wrong answer.
- **A command is recorded.** When an effect leaves the system (an email, a published event, a payment charge), a Spy that records it is the evidence. Assert on the recorded content: the recipient, the amount, the event payload.
  **Stops where:** a suite already built on mocks keeps its existing tests; write the new ones against a Fake and leave the rewrite for a separate change. A real dependency that is fast and deterministic (a pure function, an in-process library) needs no double at all.
  **Test:** would a behaviour-preserving refactor of the code under test break this test? Would an implementation that passes the wrong id or currency still pass it?

## Done

Every test you added was seen red, through the bug it reproduces or a sabotage you reverted; every law of the code under test is a property over generated input; every assertion checks a return value, posterior state or the content of a recorded command. Your summary lists, for each test, how you saw it fail.
