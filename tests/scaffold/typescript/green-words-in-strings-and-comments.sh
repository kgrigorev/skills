# expect: green
# Words the greps look for, in strings and comments where they switch nothing off.
cat >src/messages.ts <<'X'
// The clock comes from the caller: Date.now() here would make the output depend on the time.
/** Explains why the build failed, for a person reading the log. */
export function explain(code: number, startedAt: number): string {
  const elapsed = Date.now() - startedAt;
  return code === 0
    ? `done in ${elapsed} ms`
    : `failed with ${code}; run again with a fresh seed or skip the cache`;
}
X
cat >tests/messages.test.ts <<'X'
import { expect, it } from "vitest";
import { explain } from "../src/messages.ts";

// Times are fixed numbers, so the test gives the same result on every run.
it("says how long a good build took", () => {
  expect(explain(0, 0)).toMatch(/^done in [0-9]+ ms$/);
});

it("suggests what to try when a build fails", () => {
  expect(explain(2, 0)).toContain("skip the cache");
});
X
