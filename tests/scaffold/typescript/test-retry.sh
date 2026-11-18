# expect: red Test (vitest)
# A retry option, which turns a flaky test green.
cat >tests/extra.test.ts <<'X'
import { expect, it } from "vitest";

it("r", { retry: 2 }, () => {
  expect(1).toBe(1);
});
X
