# expect: green
# Regression examples and an async property, with the seed and run count from tests/setup.ts.
cat >tests/extra.test.ts <<'X'
import * as fc from "fast-check";
import { expect, it } from "vitest";
import { greet } from "../src/sample-tool.ts";

it("greets with regression examples", () => {
  fc.assert(
    fc.property(fc.string(), (name) => {
      expect(greet(name).startsWith("Hello, ")).toBe(true);
    }),
    { examples: [[""], ["  "]] },
  );
});

it("greets asynchronously", async () => {
  await fc.assert(
    fc.asyncProperty(fc.string(), async (name) => {
      const text = await Promise.resolve(greet(name));
      expect(text.endsWith("!")).toBe(true);
    }),
  );
});
X
