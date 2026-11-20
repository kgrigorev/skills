# expect: red Lint (oxlint
# An inline /* eslint rule: "off" */ config comment.
cat >>src/sample-tool.ts <<'X'

/* eslint typescript/no-explicit-any: "off" */
/** Anything. */
export function anything(v: any): any {
  return v;
}
X
perl -pi -e 's/import \{ banner, greet \}/import { anything, banner, greet }/' src/main.ts
echo 'console.log(anything(1));' >>src/main.ts
