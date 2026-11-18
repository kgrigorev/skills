# expect: red Test (vitest)
# MISE_ENV from the caller's shell, which would load mise.loose.toml and its NODE_OPTIONS.
# scripts/check unsets MISE_ENV before the re-exec, so the failing test still fails.
# env: MISE_ENV=loose
cat >mise.loose.toml <<'X'
[env]
NODE_OPTIONS = "--import=data:text/javascript,process.on('exit',()=>{process.exitCode=0})"
X
cat >tests/broken.test.ts <<'X'
import { expect, it } from "vitest";

it("fails", () => {
  expect(1).toBe(2);
});
X
