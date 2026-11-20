# expect: red Lint (oxlint
# A triple-slash reference adds the DOM types, which Node does not have: tsc passes, and the
# program fails with "document is not defined".
cat >>src/sample-tool.ts <<'X'

/** The page title. */
export function title(): string {
  return document.title;
}
X
{ printf '/// <reference lib="dom" />\n'; cat src/sample-tool.ts; } > s.tmp && mv s.tmp src/sample-tool.ts
perl -pi -e 's/import \{ banner, greet \}/import { banner, greet, title }/' src/main.ts
echo 'console.log(title());' >>src/main.ts
