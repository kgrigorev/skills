---
name: principle-type-system-discipline
description: "Apply when designing types, reviewing a function signature, or writing code in any statically-typed language. Make illegal states unrepresentable, brand semantic primitives, parse external data at boundaries, refuse to lie to the compiler, exhaust variants, derive from authoritative schemas."
---

# Type System Discipline

The type checker is a proof assistant. Use it to eliminate impossible states, mismatched primitives, and unhandled variants at compile time. Anything you let through as runtime data becomes a runtime failure the compiler could have stopped.

Applies to any typed language. When the project's coding standards limit type-level features, the standards win.

**The patterns:**

- **Make illegal states unrepresentable.** Model variants as sum types: discriminated unions in TypeScript, enums with payloads in Rust/Swift/Kotlin, sealed classes in Scala, ADTs in Haskell/OCaml. Don't model state as a bag of optional fields where contradictory combinations compile. A subtle anti-pattern worth naming: `{ completed: boolean; completedAt?: Date }` admits `completed: true; completedAt: undefined`, which is meaningless. Derive the boolean from a single source like `completedAt !== null`, or model the variants explicitly as `{ kind: 'open' } | { kind: 'done'; at: Date }`. If a bug forces the question "wait, can this combination actually happen?", the type is too loose.
- **Brand semantic primitives.** `UserId` and `OrderId` are strings underneath but should not be interchangeable. Newtypes in Rust, opaque types in Swift, value classes in Kotlin, a newtype with a hidden constructor and a smart constructor in Haskell, branded intersections in TypeScript. Validate once at creation, trust the type downstream.
- **External data is untyped until parsed.** RPC payloads, JSON, IPC messages, CLI args, config files, environment variables, database rows. Have a parse function at every boundary that turns unstructured input into the typed model.
- **A state that arrives at runtime is a sum type.** For example, a state read from a database row or a request. Each state holds only its own data: an expense claim is `Draft | Submitted | Approved | Paid`, and only `Paid` holds a payment reference. Do not use type-level state for it (GADTs or DataKinds in Haskell, typestate in Rust). The compiler cannot know the state of a stored value. So the check does not go away. It only moves into the parser, and the extra types cost every reader. Keep heavy type-level machinery in small, well-owned modules, where a mistake would silently corrupt data. Sources: [Parse, don't validate](https://lexi-lambda.github.io/blog/2019/11/05/parse-don-t-validate/), [A couple million lines of Haskell](https://blog.haskell.org/a-couple-million-lines-of-haskell/).
- **Don't lie to the type system.** Casts, unsafe coercions, and assertion functions that bypass the compiler are runtime crashes waiting to happen. If the compiler can't prove a fact, prove it (validate, narrow, refine the model) or accept that the cast is a hazard. The cast you bury today is the postmortem you write next week.
- **Exhaustive matching is the compiler's job.** When you match on a sum type, the compiler must fail compilation if a new variant is added without handling. Use the idiom your language provides: `never`-typed binding in TypeScript, unannotated `match` in Rust, `-Wincomplete-patterns` in Haskell, sealed-class match exhaustiveness in Kotlin.
- **Derive types from authoritative schemas.** When a protocol buffer, OpenAPI spec, GraphQL schema, database migration, or design-system token file defines a shape, derive from it instead of hand-rolling a parallel type. Manual duplication drifts.
- **Prefer compile-time over runtime.** Every runtime assertion, null check, and `instanceof` is admitting the type system isn't carrying its weight. Push the check up to the type.

**The tests:**

- "Can I write a comment explaining when this combination of fields is valid?" If yes, the type is too loose. Split it into a sum type.
- "Do two of my function arguments share a primitive type but mean different things?" Brand them.
- "Where did this `any`, this `as`, this `assertNotNull` come from?" Trace it to the boundary and validate there instead.
- "If a new variant is added next month, will the compiler tell the next agent where to add a case?" If no, the match isn't exhaustive.
- "Does this state come from a database row or a request?" Then use a sum type and a parse at the boundary, not a type-level state.
- "Is this type duplicating a shape another file owns?" Derive instead.
