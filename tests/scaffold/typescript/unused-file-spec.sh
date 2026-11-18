# expect: red Unused files, exports and dependencies (knip)
# A failing test in a .spec.ts file, which vitest does not run (it runs *.test.ts only).
cat >tests/broken.spec.ts <<'X'
import { expect, it } from "vitest";

it("fails", () => {
  expect(1).toBe(2);
});
X
