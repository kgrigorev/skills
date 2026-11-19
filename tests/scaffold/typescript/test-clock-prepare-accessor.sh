# expect: red Test (vitest)
# Error.prepareStackTrace as an accessor whose setter drops the value, so the function that
# tests/setup.ts sets never runs. The test's function reports only tests/setup.ts instead.
cat >tests/extra.test.ts <<'Y'
import { fileURLToPath } from "node:url";
import { expect, it } from "vitest";

const { random } = Math;
const setup = fileURLToPath(new URL("setup.ts", import.meta.url));
const dropped: { value: unknown } = { value: undefined };

it("chance", () => {
  Reflect.defineProperty(Error, ["prepare", "StackTrace"].join(""), {
    get: () => (): readonly string[] => [setup],
    set: (value: unknown): void => {
      dropped.value = value;
    },
    configurable: true,
  });
  expect(random()).toBeLessThan(1);
});
Y
