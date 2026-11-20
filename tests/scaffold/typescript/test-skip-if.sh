# expect: red No switched-off checks
# it.skipIf.
cat >tests/extra.test.ts <<'X'
import { expect, it } from "vitest";

it.skipIf(false)("r", () => {
  expect(1).toBe(1);
});
X
