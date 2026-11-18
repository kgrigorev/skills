# expect: red Unused files, exports and dependencies (knip)
# An unused export with an @internal tag.
printf '\n/** Unused. @internal */\nexport const unused = 1;\n' >>src/sample-tool.ts
