# expect: red Test (vitest)
# output: Counterexample:
# output: seed: 1
# A failing fc.assert must still print the counterexample and the seed that reproduce it.
cat >tests/extra.test.ts <<'X'
import * as fc from "fast-check";
import { expect, it } from "vitest";

it("small numbers", () => {
  fc.assert(
    fc.property(fc.nat(), (value) => {
      expect(value).toBeLessThan(10);
    }),
  );
});
X
