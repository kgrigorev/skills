# expect: red Lint (oxlint
# vi.setConfig switches requireAssertions off inside a test file.
cat >tests/extra.test.ts <<'X'
import { expect, it, vi } from "vitest";

vi.setConfig({ expect: { requireAssertions: false } });
it("no assertion", () => {
  expect;
});
X
