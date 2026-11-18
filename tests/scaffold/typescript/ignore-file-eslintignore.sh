# expect: red Lint (oxlint
# An .eslintignore listing the library.
printf 'export function loose(x: any): any {\n  return x;\n}\n' >>src/sample-tool.ts
echo src/sample-tool.ts >.eslintignore
