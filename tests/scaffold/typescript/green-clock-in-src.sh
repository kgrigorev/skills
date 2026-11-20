# expect: green
# Library code that reads the clock and random values (a log stamp, retry jitter), called from a
# test that checks only what does not change. tests/setup.ts guards test code only.
cat >src/log.ts <<'Y'
/** A log line: the time in ISO format, then the message. */
export function stamp(message: string): string {
  return `${new Date().toISOString()} ${message}`;
}

/** How long to wait before the next try: the base doubled per try, plus up to 10% jitter. */
export function backoffMs(attempt: number, baseMs: number): number {
  const delay = baseMs * 2 ** attempt;
  return delay + Math.floor(Math.random() * delay * 0.1);
}
Y
cat >tests/log.test.ts <<'Y'
import { expect, it } from "vitest";
import { backoffMs, stamp } from "../src/log.ts";

it("ends the line with the message", () => {
  expect(stamp("started")).toMatch(/Z started$/);
});

it("doubles the wait per try, within the jitter", () => {
  const wait = backoffMs(3, 100);
  expect(wait).toBeGreaterThanOrEqual(800);
  expect(wait).toBeLessThan(880);
});

it("compares fixed dates", () => {
  const start = new Date("2026-01-01T00:00:00Z");
  expect(new Date(start.getTime() + 86_400_000).toISOString()).toBe("2026-01-02T00:00:00.000Z");
  expect(start instanceof Date).toBe(true);
});
Y
