# expect: red Lint (oxlint
# A disable comment in upper case, which a case-sensitive grep would miss.
cat >>src/sample-tool.ts <<'X'

/** Anything. */
// OXLINT-DISABLE-NEXT-LINE
export function anything(v: any): string {
  return String(v);
}
X
perl -pi -e 's/import \{ banner, greet \}/import { anything, banner, greet }/' src/main.ts
echo 'console.log(anything(1));' >>src/main.ts
