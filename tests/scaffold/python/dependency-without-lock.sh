# expect: red Environment
# A new dependency without an updated uv.lock.
sed 's/^dependencies = \[\]$/dependencies = ["attrs"]/' pyproject.toml >pyproject.toml.new
mv pyproject.toml.new pyproject.toml
grep -q '^dependencies = \["attrs"\]$' pyproject.toml
