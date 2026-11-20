# expect: red No switched-off checks
# The current time in a test (new Date without parentheses; the formatter adds them).
cat >tests/extra.test.ts <<'X'
import { expect, it } from "vitest";

it("time", () => {
  const now = new Date;
  expect(now.getTime()).toBeGreaterThan(0);
});
X
mise exec -- pnpm exec oxfmt tests/extra.test.ts >/dev/null
