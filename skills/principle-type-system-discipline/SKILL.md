---
name: principle-type-system-discipline
description: "Type discipline: make illegal states unrepresentable; parse, don't validate. Use when designing a type or data model, writing or reviewing a function signature, handling external input (JSON, rows, env, args), deciding between null, exceptions and Result, or reaching for a cast, a non-null assertion or `any`."
---

# Type System Discipline

The type checker is a proof assistant. Each rule below moves a fact from runtime into a type, so the compiler proves it once instead of every caller checking it. Each rule ends on its **test**: a question you ask of the code.

Applies to any typed language, gradual typing included. When the project's coding standards limit type-level features, the standards win. Encode what pays for itself: each rule names where it stops. For your language's encoding of each rule, read [`references/idioms.md`](references/idioms.md).

## Model

- **Make illegal states unrepresentable.** A type is a set of values: shrink it until it matches the domain. Model alternatives as a sum type where each variant holds only its own data. `{ completed: boolean; completedAt?: Date }` admits `completed: true` with no date; `{ kind: 'open' } | { kind: 'done'; at: Date }` admits only real states. Derive a flag from the data it summarises (`completedAt !== null`) rather than storing both. Likewise, when values are merged or updated incrementally, store the parts that combine (`{ total; count }`, counters, the events) and derive the average, rate or latest value when it is read. The same move fixes an ID absent on create and present after: two types, or `{ id; item }` wrapping the creation type, rather than `id?`. An object that must be initialised before use gets everything it needs in its constructor.
  **Stops where:** sums split *behaviour*. Alternatives every caller handles identically, or an open set such as currencies, stay a runtime value in a plain field. Behaviour whose cases keep arriving from outside the module (plugins, providers, strategies) sits behind an interface or function type, so a new case is a new implementation. Rules no type can express (ranges, cross-field arithmetic) get one check in a smart constructor; rules that change faster than you ship live in configuration.
  **Test:** count the values the type admits against the states the domain has (products multiply, sums add, optional adds one); each surplus value is an illegal state. Or: could you write a comment saying when this combination of fields is valid? Then split it.
- **A state that arrives at runtime is a plain sum type.** A state read from a database row or a request is `Draft | Submitted | Approved | Paid`, parsed at the boundary, and only `Paid` holds a payment reference. Type-level state (GADTs, DataKinds, typestate) cannot help here: the compiler never sees a stored value's state, so the check only moves into the parser, and the extra types cost every reader. Keep type-level machinery in small, well-owned modules where a mistake would silently corrupt data.
  **Test:** does this state come from storage or the network? Then it is a sum type and a parse.
- **Brand semantic primitives.** `UserId` and `OrderId` are both strings and must not be interchangeable; the same goes for units (`Meters`, `Cents`) and constrained values (`Email`, `NonEmpty`). Use a distinct nominal type (a type alias is the same type under a new name), immutable, minted only by a smart constructor that validates once; downstream code trusts the brand.
  **Stops where:** a value that legitimately takes any value of its primitive and is never confused with another needs no wrapper.
  **Test:** do two arguments share a primitive type but mean different things, or does the primitive admit values the concept forbids? Brand it.

## Boundary

- **Parse, don't validate.** RPC payloads, JSON, IPC messages, CLI args, config files, environment variables and database rows are untyped until a parser turns them into the typed model, at the boundary where they enter. Past the boundary the type carries the proof, so a null check, `instanceof` or assertion deep in the code marks a type that is too loose. The parser is pure: checks that consult the database or the clock (uniqueness, "date is in the future") are business rules that run after it. When a person will fix the input, the parser collects every failure; when a later check needs an earlier result, it stops at the first.
  **Test:** where did this downstream check come from? Trace it to the boundary, parse there, and delete it here.
- **Keep wire types and domain types apart.** The wire type (the DTO the deserializer fills, the ORM entity, the generated client type) stays as wide as the wire, so bad input reaches your parser and becomes an error message. The domain type is what the parser returns. Derive the wire type from the authoritative schema (protobuf, OpenAPI, GraphQL, migration, design tokens) rather than hand-writing a copy that drifts. Inbound, wire to domain returns a Result; outbound, domain to wire always succeeds and emits only what the contract promises, so secrets and internals stay home. Bend the wire type to the tool; the domain type keeps its invariants.
  **Stops where:** a private store that the same code alone writes and reads may share the domain type.
  **Test:** does your logic run on the type the deserializer or ORM filled? Parse it into a domain type first.

## Signatures

- **The return type tells what happened.** Absence is an Option (or a nullable type the compiler checks), never a sentinel such as `-1`, `""` or an unchecked `null`; convert a null from outside into an Option where it enters. An expected failure the caller branches on is a Result whose error is a named union of cases, so the caller and the compiler can tell outcomes apart. A choice among several outcomes is a sum named in the domain's words, and the caller acts on it directly rather than reinterpreting a boolean. Bugs and unknown states (out of memory, broken invariants) stay exceptions or panics. When no caller cares why something is missing, Option says it better than Result. Each layer owns its error type; the application maps them into its own union at the edge. A step that establishes a fact (priced, approved) returns a type recording it (`Order -> PricedOrder`), so skipping or reordering the step fails to compile; `T -> T` suits steps that hold in any order, such as formatting.
  **Test:** can a caller learn every expected outcome, and every fact already established, from the signature alone?
- **Parameters ask for exactly what the function uses.** Take the values it reads, or one function or narrow interface per effect it performs, rather than a repository, container or service bundle whose signature says "needs everything, possibly". A function that cannot do its job without a value takes it as required (a `ContactableOrder` whose email is present, not an `Order` with an optional one), so the caller branches on the absence once, before the call, and the function holds no check for it.
  **Test:** does any parameter offer operations this function never calls, or admit an absence the function can only reject?
- **Tell the compiler the truth.** A cast, `any`, non-null assertion, `unwrap`, `fromJust` or partial `head` is a proof you owe. Discharge it: parse, narrow, or tighten the model until the compiler sees the fact. Open an Option or Result only where the same code says what happens in the empty or error case. When the fact truly lies beyond the type system, confine the escape hatch to one small named function whose comment states the invariant it relies on.
  **Test:** can you name what proves this cast safe? If the proof is "it always is", parse instead.
- **Exhaust every variant.** Match each variant by name, so adding one breaks the build at every site that must handle it: the compiler's errors become the worklist. A catch-all arm that handles the remaining variants turns that break into silence. Keep catch-alls for open types (integers, strings, a library's non-exhaustive enums) and for an arm that is itself the exhaustiveness check, such as TypeScript's `never` binding.
  **Test:** if a variant is added next month, will the compiler list every place to handle it?

## Done

Every type, signature, boundary and match you touched passes each rule's test. When reviewing, report each failure with the rule it breaks and the tighter type that fixes it.
