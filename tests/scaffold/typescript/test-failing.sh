# expect: red Test (vitest)
# A failing test.
perl -pi -e 's/Hello, world!/Hello!/' tests/sample-tool.test.ts
