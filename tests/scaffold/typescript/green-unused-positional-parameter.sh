# expect: green
# Parameters and keys that stay unused on purpose: one before a used parameter, and a key left out
# with a rest pattern.
cat >src/records.ts <<'Y'
/** A user as stored, with the password hash. */
export type StoredUser = { readonly name: string; readonly passwordHash: string };

/** The user without the password hash, for display. */
export function visible(user: StoredUser): Omit<StoredUser, "passwordHash"> {
  const { passwordHash: _passwordHash, ...rest } = user;
  return rest;
}

/** The positions of the items, 1-based. */
export function positions(items: readonly string[]): number[] {
  return items.map((_, index) => index + 1);
}
Y
cat >tests/records.test.ts <<'Y'
import { expect, it } from "vitest";
import { positions, visible } from "../src/records.ts";

it("drops the password hash", () => {
  expect(visible({ name: "Ada", passwordHash: "x" })).toEqual({ name: "Ada" });
});

it("numbers the items from 1", () => {
  expect(positions(["a", "b"])).toEqual([1, 2]);
});
Y
