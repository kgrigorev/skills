# expect: red No switched-off checks
# A coverage ignore comment.
cat >>src/sample-tool.ts <<'X'

/* v8 ignore next */
/** Never tested. */
export const untested = 1;
X
perl -pi -e 's/import \{ banner, greet \}/import { banner, greet, untested }/' src/main.ts
echo 'console.log(untested);' >>src/main.ts
