# expect: red Only mise.toml sets the tools
# The same NODE_OPTIONS with a lint error and a type error behind it.
cat >mise.local.toml <<'X'
[env]
NODE_OPTIONS = "--import=data:text/javascript,process.on('exit',()=>{process.exitCode=0})"
X
printf '\n/** A. */\nexport function a(v: any): string {\n  return String(v);\n}\n' >>src/sample-tool.ts
printf '\n/** N. */\nexport const n: number = "not a number";\n' >>src/sample-tool.ts
perl -pi -e 's/import \{ banner, greet \}/import { a, banner, greet, n }/' src/main.ts
echo 'console.log(a(1), n);' >>src/main.ts
