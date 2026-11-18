# expect: red No switched-off checks
# crypto.randomUUID in a test.
cat >tests/extra.test.ts <<'X'
import { expect, it } from "vitest";

it("random", () => {
  expect(crypto.randomUUID().length).toBe(36);
});
X
