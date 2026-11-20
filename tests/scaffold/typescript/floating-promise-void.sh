# expect: red Lint (oxlint
# floating-promise silenced with `void`: the write's rejection is still lost.
cat >src/save.ts <<'X'
import { writeFile } from "node:fs/promises";

/** Saves. */
export function save(text: string): void {
  void writeFile("/nonexistent/x", text);
}
X
printf 'import { save } from "./save.ts";\nsave("x");\n' >>src/main.ts
