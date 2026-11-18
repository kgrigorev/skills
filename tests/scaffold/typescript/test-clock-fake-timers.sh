# expect: red Test (vitest)
# Fake timers that would start at the real time: the test depends on today's date.
cat >tests/extra.test.ts <<'Y'
import { afterEach, expect, it, vi } from "vitest";

afterEach(() => {
  vi.useRealTimers();
});

it("time", () => {
  vi.useFakeTimers();
  const Clock = globalThis.Date;
  expect(new Clock().getFullYear()).toBeGreaterThanOrEqual(2026);
});
Y
