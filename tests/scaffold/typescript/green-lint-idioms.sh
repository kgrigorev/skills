# expect: green
# A `while (true)` loop with a break, void calls in arrow shorthands (`expect(() => f()).toThrow()`,
# `forEach((x) => console.log(x))`).
cat >>src/sample-tool.ts <<'X'

/** Reads lines until a blank one. */
export function untilBlank(lines: readonly string[]): string[] {
  const out: string[] = [];
  let index = 0;
  while (true) {
    const line = lines[index];
    if (line === undefined || line === "") break;
    out.push(line);
    index += 1;
  }
  return out;
}

/** Fails on a negative count. */
export function validate(count: number): void {
  if (count < 0) throw new RangeError("negative");
}

/** Prints each line. */
export function printAll(lines: readonly string[]): void {
  lines.forEach((line) => console.log(line));
}
X
cat >tests/extra.test.ts <<'Y'
import { expect, it, vi } from "vitest";
import { printAll, untilBlank, validate } from "../src/sample-tool.ts";

it("stops at the blank line", () => {
  expect(untilBlank(["a", "", "b"])).toEqual(["a"]);
});

it("rejects a negative count", () => {
  expect(() => validate(-1)).toThrow(RangeError);
});

it("prints each line", () => {
  const log = vi.spyOn(console, "log").mockImplementation(() => undefined);
  printAll(["a", "b"]);
  expect(log).toHaveBeenCalledTimes(2);
});
Y
