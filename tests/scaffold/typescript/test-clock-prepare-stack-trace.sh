# expect: red Test (vitest)
# Error.prepareStackTrace that returns an empty stack.
cat >tests/extra.test.ts <<'Y'
import { expect, it } from "vitest";

const { now } = Date;

it("time", () => {
  Error.prepareStackTrace = (): string => "";
  expect(now()).toBeGreaterThan(0);
});
Y
