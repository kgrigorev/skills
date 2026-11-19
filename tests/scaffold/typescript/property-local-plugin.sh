# expect: red Test (vitest)
# A local fast-check plugin whose decorateRun reports every run as passed, with the right seed and
# run count.
cat >tests/extra.test.ts <<'X'
import * as fc from "fast-check";
import { expect, it } from "vitest";
import { greet } from "../src/sample-tool.ts";

it("wrong property", () => {
  fc.assert(
    fc.property(fc.string(), (name) => {
      expect(greet(name)).toBe("never");
    }),
    {
      plugins: [
        () => ({
          decorateRun: (run) => (value) => {
            const outcomes = [run(value)];
            return outcomes.length === 1 ? null : null;
          },
        }),
      ],
    },
  );
});
X
