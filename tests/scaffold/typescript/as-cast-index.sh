# expect: red Lint (oxlint
# A cast that hides the undefined of an unchecked index.
cat >>src/sample-tool.ts <<'X'

/** First. */
export function first(xs: readonly number[]): number {
  return xs[0] as number;
}
X
perl -pi -e 's/import \{ banner, greet \}/import { banner, greet, first }/' src/main.ts
echo 'console.log(first([]));' >>src/main.ts
