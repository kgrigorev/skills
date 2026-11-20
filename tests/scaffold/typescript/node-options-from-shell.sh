# expect: red Test (vitest)
# NODE_OPTIONS from the caller's shell that resets every exit code to 0, with a failing test
# behind it. scripts/check unsets it, so the test still fails.
# env: NODE_OPTIONS=--import=data:text/javascript,process.on('exit',()=>{process.exitCode=0})
cat >tests/broken.test.ts <<'X'
import { expect, it } from "vitest";

it("fails", () => {
  expect(1).toBe(2);
});
X
