# expect: red Lint (oxlint
# A test registered only on another platform.
cat >tests/extra.test.ts <<'X'
import { expect, it } from "vitest";
import { greet } from "../src/sample-tool.ts";

if (process.platform === "win32") {
  it("greets", () => {
    expect(greet("")).toBe("wrong");
  });
}
X
