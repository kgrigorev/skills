# expect: green
# A test that fixes the clock with fake timers and fixed dates.
cat >src/age.ts <<'X'
/** Whole days from the date to now. */
export function daysSince(date: Date): number {
  return Math.floor((Date.now() - date.getTime()) / 86_400_000);
}
X
cat >tests/age.test.ts <<'X'
import { afterEach, beforeEach, expect, it, vi } from "vitest";
import { daysSince } from "../src/age.ts";

beforeEach(() => {
  vi.useFakeTimers();
  vi.setSystemTime(new Date("2026-01-10T00:00:00Z"));
});
afterEach(() => {
  vi.useRealTimers();
});

it("counts whole days", () => {
  expect(daysSince(new Date("2026-01-01T12:00:00Z"))).toBe(8);
});
X
