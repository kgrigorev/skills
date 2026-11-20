# expect: red Lint (oxlint
# A nested tsconfig.json that gives the type-aware lint rules no files.
printf '{ "files": [] }\n' >src/tsconfig.json
cat >>src/sample-tool.ts <<'X'

/** Parses. */
export function parse(text: string): number {
  const v = JSON.parse(text);
  return v.total;
}
X
perl -pi -e 's/import \{ banner, greet \}/import { banner, greet, parse }/' src/main.ts
echo 'console.log(parse("{}"));' >>src/main.ts
