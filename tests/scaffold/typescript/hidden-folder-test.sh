# expect: red Only .ts sources
# A test in a hidden folder: vitest runs it, but tsc's "**/*.ts" skips it, so its type error passed.
mkdir -p tests/.cases
cat >tests/.cases/parse.test.ts <<'X'
import { expect, it } from "vitest";
import { greet } from "../../src/sample-tool.ts";

it("greets a number", () => {
  const name: number = "Ada";
  expect(greet(String(name))).toBe("Hello, Ada!");
});
X
