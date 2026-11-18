# expect: red Lint (oxlint
# The old angle-bracket cast syntax.
cat >>src/sample-tool.ts <<'X'

/** Coerces. */
export function coerce(value: unknown): string {
  return <string>value;
}
X
perl -pi -e 's/import \{ banner, greet \}/import { banner, greet, coerce }/' src/main.ts
echo 'console.log(coerce(1));' >>src/main.ts
