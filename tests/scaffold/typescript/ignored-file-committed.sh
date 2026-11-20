# expect: red Only .ts sources, and only the gate configs
# A committed file under dist/, which the linter skips but tsc and node follow.
mkdir -p dist
cat >dist/helper.ts <<'X'
export function helper(v: any): any {
  if (v == null) return v!;
  return JSON.parse(v);
}
X
git add -f dist/helper.ts
printf 'import { helper } from "../dist/helper.ts";\nconsole.log(helper("1"));\n' >>src/main.ts
