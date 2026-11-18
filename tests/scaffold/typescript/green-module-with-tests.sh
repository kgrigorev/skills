# expect: green
# A new library module that parses outside data with a type guard, used by main.ts, with tests.
cat >src/ledger.ts <<'X'
/** One ledger entry. */
export type Entry = { readonly account: string; readonly cents: number };

/** What parsing an entry gives: the entry, or why the text is not one. */
export type Parsed =
  | { readonly ok: true; readonly entry: Entry }
  | { readonly ok: false; readonly error: string };

function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}

/** Parses one JSON entry such as {"account":"cash","cents":120}. */
export function parseEntry(text: string): Parsed {
  let value: unknown;
  try {
    value = JSON.parse(text);
  } catch (error) {
    return { ok: false, error: `not JSON: ${String(error)}` };
  }
  if (!isRecord(value)) return { ok: false, error: "not an object" };
  const account = value["account"];
  const cents = value["cents"];
  if (typeof account !== "string" || account === "") {
    return { ok: false, error: "account must be a non-empty string" };
  }
  if (typeof cents !== "number" || !Number.isInteger(cents)) {
    return { ok: false, error: "cents must be an integer" };
  }
  return { ok: true, entry: { account, cents } };
}

/** Sums the cents of every entry. */
export function total(entries: readonly Entry[]): number {
  return entries.reduce((sum, entry) => sum + entry.cents, 0);
}
X
cat >tests/ledger.test.ts <<'X'
import { describe, expect, it } from "vitest";
import { parseEntry, total } from "../src/ledger.ts";

describe("parseEntry", () => {
  it("reads a valid entry", () => {
    expect(parseEntry('{"account":"cash","cents":120}')).toEqual({
      ok: true,
      entry: { account: "cash", cents: 120 },
    });
  });

  it.each([
    ["{", "not JSON"],
    ["[]", "not an object"],
    ['{"account":"","cents":1}', "account must be a non-empty string"],
    ['{"account":"cash","cents":1.5}', "cents must be an integer"],
  ])("rejects %s", (text, error) => {
    const parsed = parseEntry(text);
    expect(parsed).toMatchObject({ ok: false });
    expect(JSON.stringify(parsed)).toContain(error);
  });
});

describe("total", () => {
  it("is zero for no entries", () => {
    expect(total([])).toBe(0);
  });
});
X
cat >>src/main.ts <<'X'

import { parseEntry } from "./ledger.ts";

const parsed = parseEntry(argv[3] ?? "{}");
console.log(parsed.ok ? `${parsed.entry.account}: ${parsed.entry.cents}` : parsed.error);
X
mise exec -- pnpm exec oxfmt src/main.ts src/ledger.ts tests/ledger.test.ts >/dev/null
