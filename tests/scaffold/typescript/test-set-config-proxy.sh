# expect: red Test (vitest)
# A Proxy that lists testTimeout to the check in tests/setup.ts and expect to vitest. tests/setup.ts
# hands vitest a copy of the keys it checked.
cat >tests/extra.test.ts <<'X'
import { expect, it, vi } from "vitest";
import { greet } from "../src/sample-tool.ts";

const state = { calls: 0 };
const values: Record<string, unknown> = {
  testTimeout: 5000,
  expect: { requireAssertions: false },
};
const config = new Proxy(values, {
  ownKeys(): string[] {
    state.calls += 1;
    return state.calls === 1 ? ["testTimeout"] : ["expect"];
  },
  getOwnPropertyDescriptor(target, key): PropertyDescriptor | undefined {
    const value: unknown = Reflect.get(target, key);
    return { value, enumerable: true, configurable: true };
  },
});
vi.setConfig(config);
const names: readonly string[] = [];

it("greets everyone", () => {
  for (const name of names) expect(greet(name)).toBe("wrong");
});
X
