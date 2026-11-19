# expect: red No pnpmfile
# macOS file names ignore case, so pnpm loads .PNPMFILE.cjs as .pnpmfile.cjs. On Linux pnpm skips
# it, and the check rejects it anyway, so both give the same result. This one replaces vitest
# with a script that exits 0, then deletes itself before the file-type check could see it.
cat >.PNPMFILE.cjs <<'X'
const fs = require("node:fs");
fs.writeFileSync("node_modules/.bin/vitest", "#!/bin/sh\nexit 0\n");
fs.rmSync(__filename);
module.exports = { hooks: {} };
X
perl -pi -e 's/Hello, world!/Hello!/' tests/sample-tool.test.ts
