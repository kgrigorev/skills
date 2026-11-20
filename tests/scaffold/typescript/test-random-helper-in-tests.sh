# expect: red Test (vitest)
# Random values from a helper module under tests/, through a destructured Math.random.
cat >tests/pick.ts <<'Y'
// Test helpers.
const { random } = Math;

/** A random index below the length. */
export function pick(length: number): number {
  return Math.floor(random() * length);
}
Y
cat >tests/extra.test.ts <<'Y'
import { expect, it } from "vitest";
import { pick } from "./pick.ts";

it("picks", () => {
  expect(pick(3)).toBeLessThan(3);
});
Y
