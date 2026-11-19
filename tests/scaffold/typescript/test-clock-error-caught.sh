# expect: red Test (vitest)
# A test that catches the error tests/setup.ts throws. The afterEach in setup.ts still fails it.
cat >tests/extra.test.ts <<'Y'
import { expect, it } from "vitest";

const { now } = Date;

function tryNow(): number {
  try {
    return now();
  } catch (error) {
    return error instanceof Error ? 1 : 0;
  }
}

it("time", () => {
  expect(tryNow()).toBeGreaterThan(0);
});
Y
