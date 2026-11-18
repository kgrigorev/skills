# expect: red Lint (oxlint
# An assertion that never runs.
cat >tests/extra.test.ts <<'X'
import { expect, it } from "vitest";
import { greet } from "../src/sample-tool.ts";

it("greets", () => {
  expect(1).toBe(1);
  if (greet("") === "never") {
    expect(greet("")).toBe("wrong");
  }
});
X
