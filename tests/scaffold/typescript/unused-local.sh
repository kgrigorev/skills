# expect: red Type check (tsc
# An unused local, which tsc reports.
perl -pi -e 's/^(?=  return )/  const unused = 1;\n/' src/sample-tool.ts
