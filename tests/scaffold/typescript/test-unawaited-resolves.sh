# expect: red Lint (oxlint
# An async assertion nobody awaits: the test ends before it settles.
cat >tests/extra.test.ts <<'X'
import { expect, it } from "vitest";
import { greet } from "../src/sample-tool.ts";

it("greets", () => {
  void expect(Promise.resolve(greet(""))).resolves.toBe("wrong");
});
X
