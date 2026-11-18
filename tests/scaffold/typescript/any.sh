# expect: red Lint (oxlint
# An explicit any.
printf '\nexport function loose(x: any): any {\n  return x;\n}\n' >>src/sample-tool.ts
