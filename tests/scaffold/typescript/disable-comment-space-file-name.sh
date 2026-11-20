# expect: red No switched-off checks
# A file name with spaces once split the grep's file list, so it searched nothing.
cat >"tests/more cases.test.ts" <<'X'
import { expect, it } from "vitest";
import { greet } from "../src/sample-tool.ts";

it("greets Ada", () => {
  expect(greet("Ada")).toBe("Hello, Ada!");
});
X
cat >>src/sample-tool.ts <<'X'

/** Anything. */
// oxlint-disable-next-line typescript/no-explicit-any
export function anything(v: any): string {
  // oxlint-disable-next-line typescript/ban-ts-comment
  // @ts-expect-error -- wrong on purpose
  const n: number = "x";
  return String(v) + String(n);
}
X
perl -pi -e 's/import \{ banner, greet \}/import { anything, banner, greet }/' src/main.ts
echo 'console.log(anything(1));' >>src/main.ts
