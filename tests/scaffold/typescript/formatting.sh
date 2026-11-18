# expect: red Format (oxfmt)
# Code that is not formatted.
perl -pi -e 's/=== ""/==""/' src/sample-tool.ts
