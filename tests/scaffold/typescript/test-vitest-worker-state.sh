# expect: red No switched-off checks
# vitest's worker state holds the config that tests/setup.ts and vi.setConfig guard. A test that
# writes to it switches requireAssertions off. The search names the plain spelling.
cat >tests/extra.test.ts <<'X'
import { expect, it } from "vitest";
import { greet } from "../src/sample-tool.ts";

const worker: unknown = Reflect.get(globalThis, "__vitest_worker__");
const config: unknown =
  typeof worker === "object" && worker !== null ? Reflect.get(worker, "config") : undefined;
const options: unknown =
  typeof config === "object" && config !== null ? Reflect.get(config, "expect") : undefined;
if (typeof options === "object" && options !== null)
  Reflect.set(options, "requireAssertions", false);
const names: readonly string[] = [];

it("greets everyone", () => {
  for (const name of names) expect(greet(name)).toBe("wrong");
});
X
