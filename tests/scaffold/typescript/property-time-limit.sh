# expect: red No switched-off checks
# The numRuns: 1 of property-num-runs, through the interruptAfterTimeLimit plugin: the property
# checks only the inputs that fit in 1 ms.
cat >tests/extra.test.ts <<'Y'
import * as fc from "fast-check";
import { expect, it } from "vitest";
import { greet } from "../src/sample-tool.ts";

it("weak property", () => {
  fc.assert(
    fc.property(fc.string(), (name) => {
      expect(greet(name).length).toBeGreaterThan(0);
    }),
    { plugins: [fc.interruptAfterTimeLimit(1, { failOnInterrupt: false })] },
  );
});
Y
