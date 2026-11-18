# expect: red Lint (oxlint
# A nested tsconfig.json that turns strict off for the type-aware lint rules.
cat >src/tsconfig.json <<'X'
{
  "compilerOptions": {
    "strict": false,
    "types": ["node"],
    "module": "nodenext",
    "noEmit": true,
    "allowImportingTsExtensions": true
  },
  "include": ["**/*.ts"]
}
X
cat >>src/sample-tool.ts <<'X'

/** Parses. */
export function parse(text: string): number {
  const v = JSON.parse(text);
  return v.total;
}
X
perl -pi -e 's/import \{ banner, greet \}/import { banner, greet, parse }/' src/main.ts
echo 'console.log(parse("{}"));' >>src/main.ts
