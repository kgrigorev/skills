# expect: red Lint (oxlint
# A cast through unknown, which turns any type into any other.
cat >>src/sample-tool.ts <<'X'

/** Coerces. */
export function coerce(value: string): number {
  return value as unknown as number;
}
X
perl -pi -e 's/import \{ banner, greet \}/import { banner, greet, coerce }/' src/main.ts
echo 'console.log(coerce("x"));' >>src/main.ts
