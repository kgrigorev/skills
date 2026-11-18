# expect: red No switched-off checks
# @ts-nocheck turns the type checker off for a whole file (lint first allows it via a disable).
cat >src/loose.ts <<'X'
// oxlint-disable typescript/ban-ts-comment
// @ts-nocheck
/** Wrong. */
export const n: number = "x";
X
printf 'import { n } from "./loose.ts";\nconsole.log(n);\n' >>src/main.ts
