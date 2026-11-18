# expect: red Unused files, exports and dependencies (knip)
# An export nothing imports.
printf '\nexport function shout(text: string): string {\n  return text.toUpperCase();\n}\n' >>src/sample-tool.ts
