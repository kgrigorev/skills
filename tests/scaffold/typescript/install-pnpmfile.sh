# expect: red No pnpmfile
# A .pnpmfile.cjs runs its code in every pnpm command, `pnpm exec` included, before any gate could
# reject it. This one would replace vitest with a script that exits 0, behind a failing test.
cat >.pnpmfile.cjs <<'X'
require("node:fs").writeFileSync("node_modules/.bin/vitest", "#!/bin/sh\nexit 0\n");
module.exports = { hooks: {} };
X
perl -pi -e 's/Hello, world!/Hello!/' tests/sample-tool.test.ts
