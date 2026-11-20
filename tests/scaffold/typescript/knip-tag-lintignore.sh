# expect: red Unused files, exports and dependencies (knip)
# An unused export with a @lintignore tag.
printf '\n/** Unused. @lintignore */\nexport const unused = 1;\n' >>src/sample-tool.ts
