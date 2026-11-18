# expect: red No switched-off checks
# it.fails passes when the test fails.
cat >tests/extra.test.ts <<'X'
import { expect, it } from "vitest";

it.fails("r", () => {
  expect(1).toBe(2);
});
X
