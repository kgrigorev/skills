# expect: red Type check (tsc
# @TS-IGNORE in upper case: tsc does not honor it, so the type error stays.
cat >>src/sample-tool.ts <<'X'

/** N. */
// @TS-IGNORE
export const n: number = "x";
X
perl -pi -e 's/import \{ banner, greet \}/import { banner, greet, n }/' src/main.ts
echo 'console.log(n);' >>src/main.ts
