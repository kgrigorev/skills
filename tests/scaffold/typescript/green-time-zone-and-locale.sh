# expect: green
# env: TZ=Asia/Tokyo
# env: LC_ALL=de_DE.UTF-8
# env: LANG=de_DE.UTF-8
# Dates and numbers print the same on every machine: scripts/check sets TZ=UTC and LC_ALL=C, so
# a laptop in Tokyo with a German locale gets the result CI gets.
cat >tests/extra.test.ts <<'X'
import { expect, it } from "vitest";

it("prints the epoch in UTC", () => {
  expect(new Date(0).getHours()).toBe(0);
});

it("prints numbers the same everywhere", () => {
  expect((1234.5).toLocaleString()).toBe("1,234.5");
});
X
