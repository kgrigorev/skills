# expect: red Test (vitest)
# Error.stackTraceLimit = 1 leaves only the frames of tests/setup.ts in the stack, so no caller
# was found under tests/.
cat >tests/extra.test.ts <<'Y'
import { expect, it } from "vitest";

const { random } = Math;

it("chance", () => {
  Error.stackTraceLimit = 1;
  expect(random()).toBeLessThan(1);
});
Y
