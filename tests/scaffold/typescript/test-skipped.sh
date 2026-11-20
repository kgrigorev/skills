# expect: red Lint (oxlint
# A skipped test.
perl -pi -e 's/it\("greets the world/it.skip("greets the world/' tests/sample-tool.test.ts
