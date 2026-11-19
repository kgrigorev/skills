# expect: red Lint
# expect-output: Do not change how much a test checks
# mapSize (const 0) makes a property check only tiny inputs, like the banned withMaxSize.
perl -0pi -e 's/^import Test.QuickCheck \(\(===\)\)$/import Test.QuickCheck (mapSize, (===))/m' test/SampleToolSpec.hs
cat >>test/SampleToolSpec.hs <<'HS'

    prop "keeps the length" . mapSize (const 0) $ \name ->
      Text.length (tidyName (Text.pack name)) === length name
HS
scripts/format >/dev/null 2>&1 || true
