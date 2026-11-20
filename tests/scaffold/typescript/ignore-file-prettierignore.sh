# expect: red Format (oxfmt)
# A .prettierignore listing a badly formatted file.
perl -pi -e 's/=== ""/==""/' src/sample-tool.ts
echo src/sample-tool.ts >.prettierignore
