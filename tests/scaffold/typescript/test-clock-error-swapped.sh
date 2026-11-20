# expect: red Test (vitest)
# Node calls globalThis.Error.prepareStackTrace, not the one on the Error that tests/setup.ts kept.
# A test that swaps globalThis.Error for the call decides what the stack shows: only setup.ts.
cat >tests/extra.test.ts <<'Y'
import { fileURLToPath } from "node:url";
import { expect, it } from "vitest";

const { random } = Math;
const setup = fileURLToPath(new URL("setup.ts", import.meta.url));
const RealError = Error;

it("chance", () => {
  const fake = { [["prepare", "StackTrace"].join("")]: (): readonly string[] => [setup] };
  let value = 2;
  Reflect.set(globalThis, "Error", fake);
  try {
    value = random();
  } catch (error) {
    value = error === undefined ? 3 : 0.5;
  } finally {
    Reflect.set(globalThis, "Error", RealError);
  }
  expect(value).toBeLessThan(1);
});
Y
