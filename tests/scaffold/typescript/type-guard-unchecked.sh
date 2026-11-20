# expect: red Lint (oxlint
# A type predicate that checks nothing: the as-cast of as-cast.sh, moved into a guard.
cat >>src/sample-tool.ts <<'X'

/** Totals. */
export type Totals = { readonly total: number };

function isTotals(_value: unknown): _value is Totals {
  return true;
}

/** Parses. */
export function parse(text: string): Totals {
  const value: unknown = JSON.parse(text);
  if (isTotals(value)) return value;
  throw new Error("not totals");
}
X
perl -pi -e 's/import \{ banner, greet \}/import { banner, greet, parse }/' src/main.ts
echo 'console.log(parse("{}").total);' >>src/main.ts
