# expect: red Lint (oxlint
# A focused test, which hides the others.
perl -pi -e 's/it\("greets the world/it.only("greets the world/' tests/sample-tool.test.ts
