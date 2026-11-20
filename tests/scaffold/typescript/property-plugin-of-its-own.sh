# expect: red Test (vitest)
# A plugin of its own next to a seed through a computed key: options cannot remove the plugin
# that tests/setup.ts installs.
cat >tests/extra.test.ts <<'Y'
import * as fc from "fast-check";
import { expect, it } from "vitest";
import { greet } from "../src/sample-tool.ts";

const key = ["se", "ed"].join("");
it("seeded", () => {
  fc.assert(
    fc.property(fc.string(), (name) => {
      expect(greet(name).length).toBeGreaterThan(0);
    }),
    { plugins: [() => ({ onAllRunsComplete: () => undefined })], [key]: 7 },
  );
});
Y
