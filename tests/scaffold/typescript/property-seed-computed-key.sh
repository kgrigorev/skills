# expect: red Lint (oxlint
# A seed set through a computed key, from the clock.
cat >tests/extra.test.ts <<'X'
import * as fc from "fast-check";
import { expect, it } from "vitest";
import { greet } from "../src/sample-tool.ts";

const key = "se" + "ed";
it("seeded", () => {
  fc.assert(
    fc.property(fc.string(), (name) => {
      expect(greet(name).length).toBeGreaterThan(0);
    }),
    { [key]: Date["now"]() },
  );
});
X
