# Idioms by language

Each rule of [`SKILL.md`](../SKILL.md) in one language's terms. Read only your language's section. **Absence/failure** encodes *The return type tells what happened*; **Escape hatches** lists the forms that *Tell the compiler the truth* asks you to discharge or confine.

## TypeScript

- **Sum type:** a discriminated union on a literal tag: `{ kind: 'open' } | { kind: 'done'; at: Date }`.
- **Brand:** `type UserId = string & { readonly __brand: 'UserId' }`, minted only by a smart constructor.
- **Exhaustive:** in `switch`, end with `default: { const unreachable: never = x; throw new Error(...) }`. Turn on `strict` and typescript-eslint's `switch-exhaustiveness-check`.
- **Boundary:** type input as `unknown`, never `any`; parse with a Standard Schema validator (Zod, Valibot, ArkType) and infer the parsed type from it (`z.output<typeof Order>`); refinements and `.brand()` make that the domain type. `safeParse` returns every issue at once. Use `satisfies` to check a literal against a type without widening it.
- **Absence/failure:** `T | undefined` under `strictNullChecks`; a result union `{ ok: true; value: T } | { ok: false; error: E }` with `E` a tagged union.
- **Escape hatches:** `as`, `any`, `!`, `// @ts-ignore`, `// @ts-expect-error`, user-defined type guards that do not actually check.

## Python

- **Sum type:** a union of dataclasses (or pydantic models) each with a `Literal` tag field; dispatch with `match`.
- **Brand:** `UserId = NewType('UserId', str)`; for validation, a frozen dataclass with a classmethod constructor.
- **Exhaustive:** end the `match` with `case _: assert_never(x)` (`typing`, 3.11+). Run pyright or mypy in strict mode.
- **Boundary:** pydantic (`Model.model_validate`, `TypeAdapter`) or msgspec; for a discriminated union, `Field(discriminator='kind')`.
- **Absence/failure:** `T | None` (checked by pyright/mypy); for expected failures return a union of result dataclasses rather than raising.
- **Escape hatches:** `cast`, `Any`, `# type: ignore`, `TypeGuard` functions that do not actually check.

## Rust

- **Sum type:** `enum` with payloads.
- **Brand:** `struct UserId(Uuid);` with a private field and a `TryFrom` or `new` that validates.
- **Exhaustive:** `match` is exhaustive by default; name every variant of your own enums instead of `_ =>`. A foreign `#[non_exhaustive]` enum requires the wildcard.
- **Boundary:** serde `Deserialize`, with `#[serde(tag = "kind")]` for tagged enums and `#[serde(try_from = "...")]` to route through the validating constructor.
- **Absence/failure:** `Option<T>`; `Result<T, E>` with an `enum` error (`thiserror`), mapped between layers with `map_err` or `From`; `panic!` for bugs.
- **Escape hatches:** `unwrap`, `expect`, lossy `as` casts, `unsafe`, `transmute`.

## Haskell

- **Sum type:** an ADT; a variant's fields are its own, so avoid record fields shared across variants (partial selectors).
- **Brand:** `newtype` whose constructor the module does not export, plus a smart constructor returning `Maybe` or `Either`.
- **Exhaustive:** `-Wall` (includes `-Wincomplete-patterns`, `-Wincomplete-uni-patterns`, `-Wincomplete-record-updates`) with `-Werror` in CI.
- **Boundary:** aeson `FromJSON` instances, or a parser per input source returning `Either`; derive from the schema with code generation where one exists.
- **Absence/failure:** `Maybe`; `Either` with a module-owned error ADT; `Validation` (e.g. from `validation-selective`) to collect every error.
- **Escape hatches:** `fromJust`, `head`, `tail`, `!!`, `read`, `error`, `undefined`, `unsafeCoerce`, `unsafePerformIO`. GHC 9.8+ flags some with `-Wx-partial`.

## Kotlin

- **Sum type:** `sealed interface` with `data class` and `data object` variants.
- **Brand:** `@JvmInline value class UserId(val value: String)` with validation in `init`.
- **Exhaustive:** `when` over a sealed type or enum, with no `else` branch.
- **Boundary:** kotlinx.serialization `@Serializable` sealed hierarchies (class discriminator), then validate into value classes.
- **Absence/failure:** `T?` (compiler-checked); a sealed result hierarchy for expected failures; exceptions for bugs.
- **Escape hatches:** `!!`, unchecked `as`, `lateinit` read before assignment, `@Suppress("UNCHECKED_CAST")`.

## Swift

- **Sum type:** `enum` with associated values.
- **Brand:** `struct UserId: Hashable { let rawValue: String }` with a failable or throwing `init`.
- **Exhaustive:** `switch` with no `default` over your own enums; `@unknown default` for non-frozen library enums.
- **Boundary:** `Decodable` with a custom `init(from:)` that validates.
- **Absence/failure:** `Optional`; `Result<T, E>` or typed `throws(E)` (Swift 6) with an `enum` error.
- **Escape hatches:** `!`, `as!`, `try!`, `unsafeBitCast`.

## Scala 3

- **Sum type:** `enum` with parameters, or a `sealed trait` with case classes.
- **Brand:** `opaque type UserId = String` with a validating constructor in its companion.
- **Exhaustive:** match exhaustivity warnings on sealed types, made fatal with `-Werror`.
- **Boundary:** circe or zio-json decoders, with validation in the decoder.
- **Absence/failure:** `Option`; `Either` with a sealed error type; cats `Validated`/`EitherNel` to collect every error.
- **Escape hatches:** `asInstanceOf`, `Option.get`, `null`, `@unchecked`.

## Java 21+

- **Sum type:** `sealed interface` permitting `record` variants.
- **Brand:** `record UserId(String value)` validating in its compact constructor.
- **Exhaustive:** a `switch` expression with record patterns over the sealed type, with no `default`.
- **Boundary:** Jackson into records (with `@JsonTypeInfo` for the sealed type), then Bean Validation or constructor checks.
- **Absence/failure:** `Optional` for return values; a sealed result interface for expected failures; exceptions for bugs.
- **Escape hatches:** casts, `Optional.get`, raw types, `@SuppressWarnings("unchecked")`.

## Go

Go has no sum types, so the compiler cannot carry the exhaustive check; a linter must.

- **Sum type:** an interface with an unexported marker method, one struct per variant; dispatch with a type switch.
- **Brand:** a defined type (`type UserID string`) for distinctness; a struct with an unexported field plus a constructor when the value needs validation.
- **Exhaustive:** golangci-lint's `gochecksumtype` for sealed interfaces and `exhaustive` for enum constants.
- **Boundary:** `encoding/json` into a wire struct, then a function that validates it into the domain type.
- **Absence/failure:** `(T, bool)` comma-ok for absence; `(T, error)` with sentinel or typed errors checked via `errors.Is`/`errors.As`; `errors.Join` to collect several.
- **Escape hatches:** type assertions without `, ok`, `any`, ignored errors, `unsafe`.

## OCaml

- **Sum type:** a variant type.
- **Brand:** an abstract type in the `.mli`, with a validating constructor.
- **Exhaustive:** warning 8 (non-exhaustive match) made an error; avoid `_` over your own variants (warning 4 flags fragile matches).
- **Boundary:** ppx_deriving_yojson or ppx_yojson_conv, then validate.
- **Absence/failure:** `option`; `result` with a variant error type; exceptions for bugs.
- **Escape hatches:** `Obj.magic`, `Option.get`, `List.hd`, `assert false`.
