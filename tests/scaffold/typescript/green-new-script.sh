# expect: green
# A second program under scripts/ with its own package.json script.
cat >scripts/report.ts <<'X'
// Prints the banner, for release notes.
import { banner } from "../src/sample-tool.ts";

console.log(banner);
X
perl -pi -e 's/^(\s*)"start": (.*),$/$1"start": $2,\n$1"report": "node scripts\/report.ts",/' package.json
grep -q '"report"' package.json
