# expect: red Only .ts sources, and only the gate configs
# A nested .gitignore that hides a committed file from the linter.
mkdir -p src/util
printf 'loose.ts\n' >src/util/.gitignore
cat >src/util/loose.ts <<'X'
export function helper(v: any): any {
  if (v == null) return v!;
  return JSON.parse(v);
}
X
git add -f src/util/loose.ts
printf 'import { helper } from "./util/loose.ts";\nconsole.log(helper("1"));\n' >>src/main.ts
