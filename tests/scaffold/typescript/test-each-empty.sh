# expect: red Test (vitest)
# it.each over an empty table runs no test.
cat >tests/extra.test.ts <<'X'
import { expect, it } from "vitest";
import { greet } from "../src/sample-tool.ts";

const cases: readonly string[] = [];
it.each(cases)("greets %s", (name) => {
  expect(greet(name)).toBe("wrong");
});
X
