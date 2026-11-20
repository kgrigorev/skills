# expect: red No switched-off checks
# process.hrtime in a test.
cat >tests/extra.test.ts <<'X'
import { expect, it } from "vitest";

it("r", () => {
  expect(process.hrtime.bigint() > 0n).toBe(true);
});
X
