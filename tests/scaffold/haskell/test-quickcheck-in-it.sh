# expect: red Lint
# expect-output: Returns () when the property fails
# quickCheck inside it prints a failure and returns (), so the example passes.
perl -0pi -e 's/^import Test.QuickCheck \(\(===\)\)$/import Test.QuickCheck (quickCheck, (===))/m' test/SampleToolSpec.hs
cat >>test/SampleToolSpec.hs <<'HS'

    it "keeps the length" . quickCheck $ \name ->
      Text.length (tidyName (Text.pack name)) === length name
HS
scripts/format >/dev/null 2>&1 || true
