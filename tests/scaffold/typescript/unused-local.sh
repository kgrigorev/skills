# expect: red Lint (oxlint
# An unused local, which oxlint (eslint/no-unused-vars) and tsc report.
perl -pi -e 's/^(?=  return )/  const unused = 1;\n/' src/sample-tool.ts
