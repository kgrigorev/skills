# expect: red No switched-off checks
# Math["random"] in a test.
cat >tests/extra.test.ts <<'X'
import { expect, it } from "vitest";

it("r", () => {
  expect(Math["random"]()).toBeLessThan(2);
});
X
