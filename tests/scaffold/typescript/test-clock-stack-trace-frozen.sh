# expect: red Test (vitest)
# Error.stackTraceLimit fixed at 0 under a computed name, so tests/setup.ts cannot raise it for the
# capture. The check fails closed.
cat >tests/extra.test.ts <<'Y'
import { expect, it } from "vitest";

const { random } = Math;

it("chance", () => {
  Reflect.defineProperty(Error, ["stackTrace", "Limit"].join(""), { value: 0, writable: false });
  expect(random()).toBeLessThan(1);
});
Y
