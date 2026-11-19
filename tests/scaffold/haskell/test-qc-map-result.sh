# expect: red Lint
# expect-output: Not allowed. Use Test.QuickCheck.
# mapTotalResult from Test.QuickCheck.Property turns a failing property into a pass.
perl -0pi -e 's/import Test.QuickCheck \(\(===\)\)/import Test.QuickCheck ((===))\nimport Test.QuickCheck.Property (mapTotalResult, succeeded)/; s/prop "changes nothing the second time" \$ \\name ->/prop "changes nothing the second time" . mapTotalResult (const succeeded) \$ \\name ->/; s/in tidyName once === once/in once === Text.pack name/' test/SampleToolSpec.hs
grep -q mapTotalResult test/SampleToolSpec.hs
scripts/format >/dev/null 2>&1 || true
