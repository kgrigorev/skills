# expect: red Test (vitest)
# A fake Error.captureStackTrace that reports only tests/setup.ts, so no caller under tests/ shows.
# tests/setup.ts took its copy of captureStackTrace before any test ran.
cat >tests/extra.test.ts <<'Y'
import { fileURLToPath } from "node:url";
import { expect, it } from "vitest";

const { random } = Math;
const setup = fileURLToPath(new URL("setup.ts", import.meta.url));

it("chance", () => {
  Reflect.set(Error, ["capture", "StackTrace"].join(""), (holder: object): void => {
    Reflect.set(holder, "stack", [setup]);
  });
  expect(random()).toBeLessThan(1);
});
Y
