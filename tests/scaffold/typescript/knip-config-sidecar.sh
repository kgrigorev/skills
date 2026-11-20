# expect: red Unused files, exports and dependencies (knip)
# A knip.json next to knip.jsonc that ignores a dead file.
printf '{ "ignore": ["src/dead.ts"] }\n' >knip.json
printf '/** Dead. */\nexport const dead = 1;\n' >src/dead.ts
