# expect: red Only .ts sources
# A script in a hidden folder with a type error, run by a package.json script.
mkdir -p .tools
cat >.tools/report.ts <<'X'
import { banner } from "../src/sample-tool.ts";

const width: number = banner;
console.log(width);
X
perl -pi -e 's/^(\s*)"start": (.*),$/$1"start": $2,\n$1"report": "node .tools\/report.ts",/' package.json
