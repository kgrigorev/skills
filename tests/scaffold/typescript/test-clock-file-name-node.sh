# expect: red Test (vitest)
# A test file whose name contains "node:", which looked like a built-in frame to a substring match.
cat >'tests/node:clock.test.ts' <<'Y'
import { expect, it } from "vitest";

const { now } = Date;
const { random } = Math;

it("time and chance", () => {
  expect(now()).toBeGreaterThan(0);
  expect(random()).toBeLessThan(1);
});
Y
