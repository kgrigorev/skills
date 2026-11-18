# expect: red No switched-off checks
# A declaration file for an arbitrary extension (.d.json.ts), declaring a global that does not
# exist. `import type` makes it a module without an empty `export {}`.
cat >src/globals.d.json.ts <<'Y'
import type { Buffer } from "node:buffer";

declare global {
  function parseLedger(text: Buffer | string): number;
}
Y
echo 'console.log(parseLedger("x"));' >>src/main.ts
