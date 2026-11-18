# expect: green
# Valid file names with spaces, non-ASCII letters and punctuation.
cat >src/données.ts <<'X'
/** Doubles a number. */
export function double(value: number): number {
  return value * 2;
}
X
cat >"tests/edge cases.test.ts" <<'X'
import { expect, it } from "vitest";
import { double } from "../src/données.ts";
import { greet } from "../src/sample-tool.ts";

it("greets a name with spaces inside", () => {
  expect(greet("  Ada Lovelace ")).toBe("Hello, Ada Lovelace!");
});

it("doubles", () => {
  expect(double(2)).toBe(4);
});
X
cat >tests/greet_v2+extra.test.ts <<'X'
import { expect, it } from "vitest";
import { greet } from "../src/sample-tool.ts";

it("keeps punctuation", () => {
  expect(greet("O'Brien")).toBe("Hello, O'Brien!");
});
X
