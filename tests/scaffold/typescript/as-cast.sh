# expect: red Lint (oxlint
# A cast that claims the shape of parsed JSON without checking it.
cat >>src/sample-tool.ts <<'X'

/** Parses. */
export function parse(text: string): { total: number } {
  const value: unknown = JSON.parse(text);
  return value as { total: number };
}
X
perl -pi -e 's/import \{ banner, greet \}/import { banner, greet, parse }/' src/main.ts
echo 'console.log(parse("{}").total);' >>src/main.ts
