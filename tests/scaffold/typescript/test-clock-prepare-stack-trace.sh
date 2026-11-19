# expect: red Test (vitest)
# Error.prepareStackTrace that returns an empty stack, set under a computed name that the search
# cannot see.
cat >tests/extra.test.ts <<'Y'
import { expect, it } from "vitest";

const { now } = Date;

it("time", () => {
  Reflect.set(Error, ["prepare", "StackTrace"].join(""), (): string => "");
  expect(now()).toBeGreaterThan(0);
});
Y
