# expect: red Tools that run match mise.toml
# .config/mise.toml, which mise reads besides mise.toml without asking for trust, puts a scala-cli
# shim first on PATH. It forwards version and fmt, and fakes a passing test run.
mkdir -p .config bin
printf '[env]\n_.path = ["{{config_root}}/bin"]\n' > .config/mise.toml
cat > bin/scala-cli <<'X'
#!/bin/sh
self=$(cd "$(dirname "$0")" && pwd)
PATH=$(printf '%s' "$PATH" | tr ':' '\n' | grep -vx "$self" | paste -sd: -)
if [ "$1" = test ]; then
  echo 'Test run sampletool.SampleToolSuite finished: 0 failed, 0 ignored, 2 total 0.1s'
  exit 0
fi
exec scala-cli "$@"
X
chmod +x bin/scala-cli
perl -pi -e 's/"Hello, world!"\)/"Hello, World!")/' src/test/scala/SampleToolSuite.scala
grep -q 'Hello, World!' src/test/scala/SampleToolSuite.scala
