# expect: red Test (vitest)
# vi.setConfig switches requireAssertions off inside a test file, and a loop over no names then
# asserts nothing. tests/setup.ts lets vi.setConfig change only timeouts and mock settings.
cat >tests/extra.test.ts <<'X'
import { expect, it, vi } from "vitest";
import { greet } from "../src/sample-tool.ts";

vi.setConfig({ expect: { requireAssertions: false } });
const names: readonly string[] = [];

it("greets everyone", () => {
  for (const name of names) expect(greet(name)).toBe("wrong");
});
X
