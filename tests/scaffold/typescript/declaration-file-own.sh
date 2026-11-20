# expect: red Only .ts sources, and only the gate configs
# A .d.ts of our own, which skipLibCheck would skip.
printf 'declare function parseLedger(text: string): number;\n' >src/globals.d.ts
echo 'console.log(parseLedger("x"));' >>src/main.ts
