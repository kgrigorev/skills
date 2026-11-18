# expect: red Test (vitest)
# ctx.skip() inside the test body.
cat >tests/extra.test.ts <<'X'
import { expect, it } from "vitest";

it("skips itself", (ctx) => {
  ctx.skip();
  expect(1).toBe(2);
});
X
