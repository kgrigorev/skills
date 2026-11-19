# expect: red Test (vitest)
# String.prototype.startsWith and Array.prototype.find patched, so a check that used them would
# find no caller under tests/. tests/setup.ts compares with plain loops.
cat >tests/extra.test.ts <<'Y'
import { expect, it } from "vitest";

const { random } = Math;

it("chance", () => {
  Reflect.set(String.prototype, "startsWith", (): boolean => false);
  Reflect.set(Array.prototype, "find", (): undefined => undefined);
  Reflect.set(Array.prototype, "includes", (): boolean => true);
  expect(random()).toBeLessThan(1);
});
Y
