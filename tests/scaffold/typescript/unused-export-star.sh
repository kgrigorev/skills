# expect: red Unused files, exports and dependencies (knip)
# Dead code re-exported with export *.
printf '/** Unused. */\nexport const deadA = 1;\n/** Unused. */\nexport const deadB = 2;\n' >src/extra.ts
printf '\nexport * from "./extra.ts";\n' >>src/sample-tool.ts
