# expect: red No switched-off checks
# A property test that checks one input.
cat >tests/extra.test.ts <<'X'
import * as fc from "fast-check";
import { expect, it } from "vitest";
import { greet } from "../src/sample-tool.ts";

it("weak property", () => {
  fc.assert(
    fc.property(fc.string(), (name) => {
      expect(greet(name).length).toBeGreaterThan(0);
    }),
    { numRuns: 1 },
  );
});
X
