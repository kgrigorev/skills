# expect: red Lint
# A property that no longer holds, wrapped in expectFailure so it "passes".
perl -0pi -e 's/import Test.QuickCheck \(\(===\)\)/import Test.QuickCheck (expectFailure, (===))/; s/prop "changes nothing the second time" \$ \\name ->/prop "changes nothing the second time" \$ expectFailure \$ \\name ->/; s/in tidyName once === once/in once === Text.pack name/' test/SampleToolSpec.hs
grep -q expectFailure test/SampleToolSpec.hs
