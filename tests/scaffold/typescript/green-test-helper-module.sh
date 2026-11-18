# expect: green
# A shared helper module for tests and a new test file that uses it.
cat >tests/names.ts <<'X'
/** Names used by several tests. */
export const names: readonly string[] = ["Ada", "Grace", "Linus"];
X
cat >tests/greet-names.test.ts <<'X'
import { expect, it } from "vitest";
import { greet } from "../src/sample-tool.ts";
import { names } from "./names.ts";

it.each(names)("greets %s", (name) => {
  expect(greet(name)).toBe(`Hello, ${name}!`);
});
X
