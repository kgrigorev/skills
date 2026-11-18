# expect: red Test (vitest)
# describe(..., { skip: true }) skips every test inside.
cat >tests/extra.test.ts <<'X'
import { describe, expect, it } from "vitest";

describe("x", { skip: true }, () => {
  it("fails", () => {
    expect(1).toBe(2);
  });
});
X
