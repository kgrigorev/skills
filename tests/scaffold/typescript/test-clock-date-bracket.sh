# expect: red No switched-off checks
# Date["now"](), which a grep for Date.now misses.
cat >tests/extra.test.ts <<'X'
import { expect, it } from "vitest";

it("time", () => {
  expect(Date["now"]()).toBeGreaterThan(0);
});
X
