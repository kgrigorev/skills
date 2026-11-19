# expect: red Test (vitest)
# A run count from a computed key, and the global plugin's error caught with toThrow: the property
# that fails at 200 runs ran once. The afterEach in tests/setup.ts still fails the test.
cat >tests/extra.test.ts <<'Y'
import * as fc from "fast-check";
import { expect, it } from "vitest";

it("all small", () => {
  const options = { [["num", "Runs"].join("")]: 1 };
  expect(() => {
    fc.assert(
      fc.property(fc.nat({ max: 50 }), (n) => n !== 3),
      options,
    );
  }).toThrow(/A property test ran/);
});
Y
