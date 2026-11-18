# expect: red Lint (oxlint
# A promise nobody awaits: its rejection is lost.
cat >src/save.ts <<'X'
import { writeFile } from "node:fs/promises";

/** Saves. */
export function save(text: string): void {
  writeFile("/nonexistent/x", text);
}
X
printf 'import { save } from "./save.ts";\nsave("x");\n' >>src/main.ts
