# expect: red Lint (oxlint
# An assertion function with an empty body: `asserts value is T` without a check.
cat >>src/sample-tool.ts <<'X'

/** Totals. */
export type Totals = { readonly total: number };

function assertTotals(_value: unknown): asserts _value is Totals {}

/** Parses. */
export function parse(text: string): Totals {
  const value: unknown = JSON.parse(text);
  assertTotals(value);
  return value;
}
X
perl -pi -e 's/import \{ banner, greet \}/import { banner, greet, parse }/' src/main.ts
echo 'console.log(parse("{}").total);' >>src/main.ts
