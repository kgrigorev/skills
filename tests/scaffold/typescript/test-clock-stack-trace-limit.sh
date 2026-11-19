# expect: red No switched-off checks
# Error.stackTraceLimit = 1 would leave only the frames of tests/setup.ts in the stack. The search
# names the plain spelling; test-clock-stack-trace-frozen covers a computed one at run time.
cat >tests/extra.test.ts <<'Y'
import { expect, it } from "vitest";

const { random } = Math;

it("chance", () => {
  Error.stackTraceLimit = 1;
  expect(random()).toBeLessThan(1);
});
Y
