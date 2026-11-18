# expect: red Test (vitest)
# it["skipIf"], which neither the lint rule nor the grep sees.
cat >tests/extra.test.ts <<'X'
import { expect, it } from "vitest";

it["skipIf"](true)("skipped", () => {
  expect(1).toBe(2);
});
X
