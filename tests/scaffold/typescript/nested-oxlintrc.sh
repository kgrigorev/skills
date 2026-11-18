# expect: red Lint (oxlint
# A nested .oxlintrc.json that switches a rule off for its folder.
mkdir -p src/x
printf '{ "rules": { "typescript/no-explicit-any": "off" } }\n' >src/x/.oxlintrc.json
printf 'export function a(v: any): string {\n  return String(v);\n}\n' >src/x/a.ts
printf 'import { a } from "./x/a.ts";\nconsole.log(a(1));\n' >>src/main.ts
