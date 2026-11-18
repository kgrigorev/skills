# expect: red Test (vitest)
# The current time through an alias of the Date constructor.
cat >tests/extra.test.ts <<'Y'
import { expect, it } from "vitest";

const Clock = Date;

it("time", () => {
  expect(new Clock().getFullYear()).toBeGreaterThanOrEqual(2026);
});
Y
