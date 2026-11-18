# expect: red Test (vitest)
# The clock and random values through destructuring, an alias and brackets, which the search of
# the source cannot see.
cat >tests/extra.test.ts <<'Y'
import { expect, it } from "vitest";

const { now } = Date;
const M = Math;

it("time and chance", () => {
  expect(now()).toBeGreaterThan(0);
  expect(M.random()).toBeLessThan(1);
  expect(performance["now"]()).toBeGreaterThan(0);
});
Y
