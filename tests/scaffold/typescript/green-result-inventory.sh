# expect: green
# A Result type, a Map-backed inventory with an exhaustive never check, satisfies, and a property
# test over fc.record with conditions inside the property.
cat >src/inventory.ts <<'X'
/** A value or the reason there is none. */
export type Result<T, E> =
  | { readonly ok: true; readonly value: T }
  | { readonly ok: false; readonly error: E };

/** A change to the stock of one item. */
export type Change =
  | { readonly op: "add"; readonly sku: string; readonly count: number }
  | { readonly op: "remove"; readonly sku: string; readonly count: number }
  | { readonly op: "clear"; readonly sku: string };

/** Why a change could not be applied. */
export type Problem = "unknown sku" | "not enough stock";

const limits = { maxPerSku: 1000 } as const satisfies Record<string, number>;

function unreachable(value: never): never {
  throw new Error(`unhandled change: ${JSON.stringify(value)}`);
}

/** Applies a change to the stock, without changing the map that goes in. */
export function apply(
  stock: ReadonlyMap<string, number>,
  change: Change,
): Result<ReadonlyMap<string, number>, Problem> {
  const next = new Map(stock);
  const current = stock.get(change.sku);
  switch (change.op) {
    case "add":
      next.set(change.sku, Math.min(limits.maxPerSku, (current ?? 0) + change.count));
      return { ok: true, value: next };
    case "remove":
      if (current === undefined) return { ok: false, error: "unknown sku" };
      if (current < change.count) return { ok: false, error: "not enough stock" };
      next.set(change.sku, current - change.count);
      return { ok: true, value: next };
    case "clear":
      if (current === undefined) return { ok: false, error: "unknown sku" };
      next.delete(change.sku);
      return { ok: true, value: next };
    default:
      return unreachable(change);
  }
}
X
cat >tests/inventory.test.ts <<'X'
import * as fc from "fast-check";
import { describe, expect, it } from "vitest";
import { apply } from "../src/inventory.ts";

describe("apply", () => {
  it("refuses to remove more than there is", () => {
    const stock = new Map([["apple", 2]]);
    expect(apply(stock, { op: "remove", sku: "apple", count: 3 })).toEqual({
      ok: false,
      error: "not enough stock",
    });
    expect(stock.get("apple")).toBe(2);
  });

  it("clears a known sku", () => {
    const result = apply(new Map([["apple", 2]]), { op: "clear", sku: "apple" });
    expect(result.ok && result.value.has("apple")).toBe(false);
  });

  it("never goes below zero", () => {
    const randomChanges = fc.array(
      fc.record({
        op: fc.constantFrom("add" as const, "remove" as const),
        sku: fc.constantFrom("a", "b"),
        count: fc.nat({ max: 20 }),
      }),
    );
    fc.assert(
      fc.property(randomChanges, (changes) => {
        let stock: ReadonlyMap<string, number> = new Map();
        for (const change of changes) {
          const result = apply(stock, change);
          if (result.ok) stock = result.value;
        }
        expect([...stock.values()].every((count) => count >= 0)).toBe(true);
      }),
    );
  });
});
X
mise exec -- pnpm exec oxfmt src/inventory.ts tests/inventory.test.ts >/dev/null
