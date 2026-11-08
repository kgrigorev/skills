---
name: functional-core
description: "Functional core, imperative shell: decisions in pure functions, I/O at the edges. Use when writing or reviewing code where business rules meet a database, an HTTP or payment API, email or a queue; when building a handler, service, background job or scheduled task; when logic reads the clock, randomness or config; or when testing a rule needs mocks, fakes or a database."
---

# Functional Core, Imperative Shell

Split the code in two. The **core** is pure: same input, same output, no effects; every business decision lives there. The **shell** is everything that touches the world (database, network, email, clock, randomness, files, environment); it gathers data, calls the core, and acts on the answer. Impure code may call pure code; pure code calls only pure code. Each rule below ends on its **test**: a question you ask of the code.

Applies in any language. The patterns are the same whether the shell is a controller, a message consumer, a cron job or `main`. For the shape of what the core returns and takes, see `type-design` (domain-named sums, parameters that ask for exactly what they use).

## Shape

- **Every entry point is a sandwich: read, calculate, write.** A handler, job, consumer or command first reads everything the decision needs, then calls one pure function with those values, then writes what the result says. Once the write phase starts, it only writes. A pure slice that parses input before the read, or formats output after the calculation, is part of the shape. The same holds inside a transaction: lock and read the rows, decide in the core, write. A batch job reads its candidates, calculates a decision per item in the core, and writes them all.
  **Stops where:** low-decision glue that is nearly all I/O (one conditional `UPDATE`, copying rows between stores) stays plain I/O; a single SQL statement is a fine answer there. When a write produces data the next decision needs (a generated ID, the next page token) or each read depends on the previous answer, the interleaving is real: keep it, and give each decision between the I/O calls its own pure function.
  **Test:** mark each line that does I/O. Do the marks form a read band above one core call and a write band below it? A business `if` between two I/O calls is logic left in the shell.
- **The core returns a decision; the shell carries it out.** The pure function returns a value naming what to do, as labelled cases holding the data each effect needs: `Warn(user, deactivateOn) | Deactivate(user) | Skip`, `Accepted(lines, total) | OutOfStock(productIds)`, `SendReminder(appointment) | NotYet | AlreadySent`. The shell's code after the call is one match that maps each case to its effects: an `UPDATE`, an email, an HTTP status.
  **Test:** does the shell's code after the core call decide anything beyond which case it received?

## Inputs

- **Time and randomness are values.** The shell reads the clock once per request or run and passes `now` in as an instant; it generates tokens, IDs and random numbers and passes them in too; it reads environment and configuration at startup and passes the values. Core signatures take `now: Instant` and `token: String`, while `Clock`, `TimeProvider`, `timezone.now()`, `SecureRandom` and `uuid4()` stay in the shell. A clock abstraction is welcome in the shell, so the shell's own integration tests can freeze time.
  **Stops where:** the moment an effect actually happened (`sent_at` after a slow send) is read in the write phase, where it is recorded.
  **Test:** search the core for clock, random, UUID, environment and config reads. Each hit becomes a parameter.
- **The core takes data, not dependencies.** Pass the core the rows, records and amounts the shell fetched, never the repository, session, `DbContext`, HTTP client or mailer that fetches them. A dependency behind an interface or passed as a function argument still performs I/O: injecting it hides the effect inside the core. Ports and adapters (`EmailSender`, `PaymentGateway`) serve the shell.
  **Stops where:** when the data cannot be fetched up front (lookups that depend item by item on earlier answers, or a set too large for memory once measured), pass the narrowest lookup function the core needs, and keep everything else as values.
  **Test:** does any core parameter do I/O when called?

## Keeping it pure

- **Impurity spreads silently: review for it.** Most languages never flag it. One `Date.now()` added to a pure-named validator makes it and every caller impure with no signature change, and its tests pass until the calendar moves past a fixture date. When you write or touch core code, check each function against this list: returns `void`, `Unit` or `None` (assume it does something); reads the clock; uses randomness, UUIDs or GUIDs; touches files, network, database or environment; is `async` or returns a `Promise`, `Task` or `Future` (asynchrony usually means I/O); reads or writes global mutable state. Logging is the one effect the core may tolerate, as long as no decision depends on it.
  **Test:** does any function in the core hit an item on the list? Move it to the shell or turn the item into a parameter.
- **Unit-test the core with values; integration-test the shell.** A test of a business rule calls the core function with dates, rows and amounts, and asserts on the decision it returns: no database, mock, fake, stub or patched clock. Table-driven cases cover the edges cheaply. The shell gets a few integration tests against real infrastructure for what only the infrastructure does: the conditional `UPDATE`, locking, the wire format.
  **Test:** does a test of a business rule build a database, a fake clock or a mock? Then the rule sits in the shell: move it to the core and test it with values.

## Wiring

- **Compose the shell at the entry point.** One composition root per application entry point (`main`, the startup file, the server bootstrap; each test is its own root) constructs the adapters and passes them in by constructor or argument. Plain code wiring (pure DI) gives compile-time errors; a container is worth it only when the codebase already runs on one or its conventions remove real wiring work. The core needs no wiring at all: it receives values.
  **Stops where:** a framework that constructs your classes (Spring, ASP.NET, NestJS) wires the shell through its own DI; keep the core out of it.
  **Test:** is each adapter constructed in one place at the entry point, and does every other class receive its collaborators rather than looking them up?
- **Climb the ladder one rung at a time.** From least to most machinery: plain I/O for glue; the sandwich (the default); a function parameter for a genuine strategy or an unavoidable lookup; injected interfaces or a Reader; an interpreter over an instruction type (free monads, effect systems). Each rung costs readers and tooling. Climb only when you can name what the rung below cannot do for this workflow.
  **Test:** for each piece of machinery you added, can you say which lower rung failed and why?

## Done

Every entry point you wrote or touched is a sandwich, or falls under a named **Stops where**; every rule's test passes. When reviewing, report each failure with the rule it breaks and the core function that fixes it: its signature, the decision type it returns, and the test that now needs no mock.
