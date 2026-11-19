# expect: red Test (vitest)
# fc.check returns a failed property instead of throwing it, so the test passed.
cat >tests/extra.test.ts <<'X'
import * as fc from "fast-check";
import { expect, it } from "vitest";
import { greet } from "../src/sample-tool.ts";

it("wrong property", () => {
  fc.check(
    fc.property(fc.string(), (name) => {
      expect(greet(name)).toBe("never");
    }),
  );
});
X
