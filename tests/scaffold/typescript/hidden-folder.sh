# expect: red Lint (oxlint
# Code in a hidden folder, which some tools skip.
mkdir -p .lib
cat >.lib/helper.ts <<'X'
export function helper(v: any): any {
  if (v == null) return v!;
  return JSON.parse(v);
}
export const deadExport = 1;
X
printf 'import { helper } from "../.lib/helper.ts";\nconsole.log(helper("1"));\n' >>src/main.ts
