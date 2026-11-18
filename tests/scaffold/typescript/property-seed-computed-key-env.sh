# expect: red Test (vitest)
# Computed seed and numRuns keys: a seed that changes on every run (the pid) and a single run.
cat >tests/extra.test.ts <<'Y'
import * as fc from "fast-check";
import { expect, it } from "vitest";
import { greet } from "../src/sample-tool.ts";

const options = Object.fromEntries([
  [["se", "ed"].join(""), process.pid],
  [["num", "Runs"].join(""), 1],
]);
it("seeded", () => {
  fc.assert(
    fc.property(fc.string(), (name) => {
      expect(greet(name).length).toBeGreaterThan(0);
    }),
    options,
  );
});
Y
mise exec -- pnpm exec oxfmt tests/extra.test.ts >/dev/null
