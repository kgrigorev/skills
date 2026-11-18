# expect: red Test (vitest)
# Retry options handed to a test from a module under src/, out of reach of the tests-only grep.
cat >src/test-options.ts <<'X'
/** Options for flaky tests. */
export const flaky = { retry: 2 };
X
cat >tests/extra.test.ts <<'X'
import { expect, it } from "vitest";
import { flaky } from "../src/test-options.ts";

it("r", flaky, () => {
  expect(1).toBe(1);
});
X
