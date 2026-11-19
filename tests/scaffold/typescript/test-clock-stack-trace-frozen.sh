# expect: red Test (vitest)
# Error.stackTraceLimit fixed at 0, so tests/setup.ts cannot raise it for the capture. The capture
# then does not show tests/setup.ts itself, and the check fails closed.
cat >tests/extra.test.ts <<'Y'
import { expect, it } from "vitest";

const { random } = Math;

it("chance", () => {
  Reflect.defineProperty(Error, "stackTraceLimit", { value: 0, writable: false });
  expect(random()).toBeLessThan(1);
});
Y
