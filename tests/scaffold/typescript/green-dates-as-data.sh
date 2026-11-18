# expect: green
# Fixed dates as test data, with a Date[] type and an index named by date.
cat >src/calendar.ts <<'X'
/** The latest of the dates, or undefined for none. */
export function latest(dates: readonly Date[]): Date | undefined {
  let best: Date | undefined;
  for (const date of dates) {
    if (best === undefined || date.getTime() > best.getTime()) best = date;
  }
  return best;
}
X
cat >tests/calendar.test.ts <<'X'
import { expect, it } from "vitest";
import { latest } from "../src/calendar.ts";

const byDate: Record<string, number> = { "2026-01-01": 1 };

it("picks the latest date", () => {
  const dates: Date[] = [
    new Date("2026-01-01T00:00:00Z"),
    new Date(Date.UTC(2026, 5, 1)),
  ];
  expect(latest(dates)?.toISOString()).toBe("2026-06-01T00:00:00.000Z");
  expect(byDate["2026-01-01"]).toBe(1);
});

it("has no latest date for none", () => {
  expect(latest([])).toBeUndefined();
});
X
mise exec -- pnpm exec oxfmt tests/calendar.test.ts >/dev/null
