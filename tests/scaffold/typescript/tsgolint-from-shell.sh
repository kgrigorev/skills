# expect: red Lint (oxlint
# env: OXLINT_TSGOLINT_PATH=/usr/bin/true
# OXLINT_TSGOLINT_PATH from the caller's shell swaps the type-aware linter for a program that
# finds nothing. scripts/check unsets it, so the unchecked cast still fails.
cat >>src/sample-tool.ts <<'X'

/** Parses. */
export function parse(text: string): { total: number } {
  const value: unknown = JSON.parse(text);
  return value as { total: number };
}
X
perl -pi -e 's/import \{ banner, greet \}/import { banner, greet, parse }/' src/main.ts
echo 'console.log(parse("{}").total);' >>src/main.ts
