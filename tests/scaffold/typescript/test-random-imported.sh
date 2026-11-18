# expect: red No switched-off checks
# randomInt imported from node:crypto in a test.
cat >tests/extra.test.ts <<'X'
import { randomInt } from "node:crypto";
import { expect, it } from "vitest";

it("r", () => {
  expect(randomInt(10)).toBeLessThan(10);
});
X
