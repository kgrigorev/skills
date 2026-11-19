# expect: red Test (vitest)
# Math.random called from a promise callback: only the async frames lead back to the test.
cat >tests/extra.test.ts <<'Y'
import { expect, it } from "vitest";

const { random } = Math;

it("chance", async () => {
  const value = await Promise.resolve().then(random);
  expect(value).toBeLessThan(1);
});
Y
