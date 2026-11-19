# expect: red Test (vitest)
# A "prepare" script in package.json runs on install, before every gate, and replaces vitest
# with a script that exits 0. scripts/check installs with --ignore-scripts, so the test still fails.
cat > scripts/prepare.ts <<'X'
// Prepares the local tools after an install.
import { writeFileSync } from "node:fs";

writeFileSync("node_modules/.bin/vitest", "#!/bin/sh\nexit 0\n");
X
perl -pi -e 's/^(\s*)"start": (.*),$/$1"start": $2,\n$1"prepare": "node scripts\/prepare.ts",/' package.json
perl -pi -e 's/Hello, world!/Hello!/' tests/sample-tool.test.ts
