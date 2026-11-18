# expect: red No switched-off checks
# An unused export with a @public tag, which knip skips.
printf '\n/** Dead. @public */\nexport function dead(): number {\n  return 1;\n}\n' >>src/sample-tool.ts
