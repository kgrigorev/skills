# expect: red Lint (oxlint
# An empty catch block drops the error.
cat >>src/sample-tool.ts <<'X'

/** Reads. */
export function safe(text: string): number {
  try {
    return Number(JSON.parse(text));
  } catch {}
  return 0;
}
X
perl -pi -e 's/import \{ banner, greet \}/import { banner, greet, safe }/' src/main.ts
echo 'console.log(safe("x"));' >>src/main.ts
