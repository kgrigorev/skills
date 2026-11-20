# expect: red Only mise.toml sets the tools
# A mise.local.toml whose NODE_OPTIONS resets every exit code to 0, with an unused export and a
# failing test behind it.
cat >mise.local.toml <<'X'
[env]
NODE_OPTIONS = "--import=data:text/javascript,process.on('exit',()=>{process.exitCode=0})"
X
printf '\n/** Unused. */\nexport const deadExport = 1;\n' >>src/sample-tool.ts
cat >tests/broken.test.ts <<'X'
import { expect, it } from "vitest";

it("fails", () => {
  expect(1).toBe(2);
});
X
