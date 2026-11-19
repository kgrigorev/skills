# expect: red Test (vitest)
# Math.random called straight from the promise queue, not awaited: no file is on the stack at all.
cat >tests/extra.test.ts <<'Y'
import { expect, it } from "vitest";

const { random } = Math;

it("chance", async () => {
  const box = { value: 2 };
  Promise.resolve()
    .then(random)
    .then((value) => {
      box.value = value;
      return value;
    })
    .catch((error: unknown) => {
      throw error;
    });
  await new Promise((resolve) => {
    setImmediate(resolve);
  });
  expect(box.value).toBeLessThan(2);
});
Y
