# expect: red No switched-off checks
# @ts-expect-error behind a disable comment for ban-ts-comment.
cat >>src/sample-tool.ts <<'X'

// oxlint-disable-next-line typescript/ban-ts-comment
// @ts-expect-error -- wrong on purpose
export const n: number = "x";
X
perl -pi -e 's/import \{ banner, greet \}/import { banner, greet, n }/' src/main.ts
echo 'console.log(n);' >>src/main.ts
