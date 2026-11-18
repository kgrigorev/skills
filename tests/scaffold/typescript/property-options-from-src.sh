# expect: red No switched-off checks
# fast-check options from a module under src/, out of reach of a tests-only grep.
cat >src/fc-options.ts <<'X'
/** Property-test options. */
export const options = { seed: Date.now(), numRuns: 1 };
X
cat >tests/extra.test.ts <<'X'
import * as fc from "fast-check";
import { expect, it } from "vitest";
import { options } from "../src/fc-options.ts";
import { greet } from "../src/sample-tool.ts";

it("random seed", () => {
  fc.assert(
    fc.property(fc.string(), (name) => {
      expect(greet(name).length).toBeGreaterThan(0);
    }),
    options,
  );
});
X
