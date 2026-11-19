# expect: red Test (vitest)
# A test file whose path starts with the path of tests/setup.ts, which looked like setup.ts itself.
cat >tests/setup.ts-cases.test.ts <<'X'
import { expect, it } from "vitest";

const { random } = Math;
it("random", () => {
  expect(random()).toBeLessThan(1);
});
X
