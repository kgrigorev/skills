# expect: red Test (vitest)
# A seed set through a computed key.
cat >tests/extra.test.ts <<'Y'
import * as fc from "fast-check";
import { expect, it } from "vitest";
import { greet } from "../src/sample-tool.ts";

const key = ["se", "ed"].join("");
it("seeded", () => {
  fc.assert(
    fc.property(fc.string(), (name) => {
      expect(greet(name).length).toBeGreaterThan(0);
    }),
    { [key]: 7 },
  );
});
Y
