# expect: red Unused files, exports and dependencies (knip)
# An unused export with a @knipignore tag.
printf '\n/** Unused. @knipignore */\nexport const unused = 1;\n' >>src/sample-tool.ts
