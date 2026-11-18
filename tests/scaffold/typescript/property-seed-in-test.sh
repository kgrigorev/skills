# expect: red No switched-off checks
# A property test with its own seed.
cat >tests/extra.test.ts <<'X'
import * as fc from "fast-check";
import { expect, it } from "vitest";

it("p", () => {
  fc.assert(
    fc.property(fc.string(), (s) => {
      expect(s.length >= 0).toBe(true);
    }),
    { seed: 7 },
  );
});
X
