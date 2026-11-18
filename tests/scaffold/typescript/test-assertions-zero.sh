# expect: red Test (vitest)
# expect.assertions(0) satisfies requireAssertions without asserting anything.
cat >tests/extra.test.ts <<'X'
import { expect, it } from "vitest";

it("does nothing", () => {
  expect.assertions(0);
});
X
