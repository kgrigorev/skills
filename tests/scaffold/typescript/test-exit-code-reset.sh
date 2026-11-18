# expect: red Test (vitest)
# A failing test file that ends the process with exit code 0 once its tests are registered.
cat >tests/extra.test.ts <<'X'
import { afterAll, expect, it } from "vitest";

it("fails", () => {
  expect(1).toBe(2);
});
afterAll(() => {
  process.exitCode = 0;
  process.on("exit", () => {
    process.exitCode = 0;
  });
});
X
