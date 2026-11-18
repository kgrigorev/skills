# expect: red Lint (oxlint
# A declaration file for an arbitrary extension (.d.json.ts), declaring a global that does not
# exist.
cat >src/globals.d.json.ts <<'X'
declare global {
  function parseLedger(text: string): number;
}
export {};
X
echo 'console.log(parseLedger("x"));' >>src/main.ts
