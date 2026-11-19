# expect: green
# vi.setConfig may still raise the timeout for a slow file.
cat >tests/extra.test.ts <<'X'
import { expect, it, vi } from "vitest";
import { greet } from "../src/sample-tool.ts";

vi.setConfig({ testTimeout: 10_000 });

it("greets", () => {
  expect(greet("Ada")).toBe("Hello, Ada!");
});
X
