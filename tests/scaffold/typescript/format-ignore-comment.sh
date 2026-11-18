# expect: red No switched-off checks
# A formatter ignore comment.
cat >>src/sample-tool.ts <<'X'

// prettier-ignore
/** Spaced. */
export const spaced = [1,2,3];
X
perl -pi -e 's/import \{ banner, greet \}/import { banner, greet, spaced }/' src/main.ts
echo 'console.log(spaced);' >>src/main.ts
