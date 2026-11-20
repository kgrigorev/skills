# expect: green
# A new property test file, with the seed and run count from tests/setup.ts.
cat >tests/greet-properties.test.ts <<'X'
import * as fc from "fast-check";
import { expect, it } from "vitest";
import { greet } from "../src/sample-tool.ts";

it("always ends with an exclamation mark", () => {
  fc.assert(
    fc.property(fc.string(), (name) => {
      expect(greet(name).endsWith("!")).toBe(true);
    }),
  );
});

it("never greets an empty name", () => {
  const randomIntegers = fc.array(fc.integer({ min: 0, max: 5 }));
  fc.assert(
    fc.property(randomIntegers, (counts) => {
      const name = counts.map((count) => " ".repeat(count)).join("");
      expect(greet(name)).toBe("Hello, world!");
    }),
  );
});
X
