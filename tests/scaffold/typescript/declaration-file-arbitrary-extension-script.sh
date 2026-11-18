# expect: red Unused files, exports and dependencies (knip)
# The same as a script file without exports, which no import reaches.
printf 'declare function parseLedger(text: string): number;\n' >src/globals.d.json.ts
echo 'console.log(parseLedger("x"));' >>src/main.ts
