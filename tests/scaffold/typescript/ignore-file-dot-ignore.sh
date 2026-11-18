# expect: red Lint (oxlint
# A .ignore file listing a source file.
printf 'src/loose.ts\n' >.ignore
cat >src/loose.ts <<'X'
export function helper(v: any): any {
  if (v == null) return v!;
  return JSON.parse(v);
}
X
printf 'import { helper } from "./loose.ts";\nconsole.log(helper("1"));\n' >>src/main.ts
