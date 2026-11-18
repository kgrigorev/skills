# expect: red Test (vitest)
# A snapshot that does not exist yet is written instead of compared.
cat >tests/extra.test.ts <<'X'
import { expect, it } from "vitest";
import { greet } from "../src/sample-tool.ts";

it("greets", () => {
  expect(greet("")).toMatchSnapshot();
});
X
