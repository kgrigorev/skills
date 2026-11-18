# expect: red Lint (oxlint
# eval and new Function run strings as code.
cat >>src/sample-tool.ts <<'X'

/** Evaluates. */
export function run(code: string): void {
  eval(code);
  new Function(code);
}
X
perl -pi -e 's/import \{ banner, greet \}/import { banner, greet, run }/' src/main.ts
echo 'run("1");' >>src/main.ts
