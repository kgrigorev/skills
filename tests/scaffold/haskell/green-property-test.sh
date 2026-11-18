# expect: green
# Another property on the existing function, with a precondition that often holds.
perl -0pi -e 's/import Test.QuickCheck \(\(===\)\)/import Test.QuickCheck (property, (===), (==>))/' test/SampleToolSpec.hs
cat >>test/SampleToolSpec.hs <<'HS'

    prop "never starts with a space" $ \name ->
      not (null name) ==>
        property (not (" " `Text.isPrefixOf` tidyName (Text.pack name)))

    prop "keeps every word" $ \name ->
      Text.words (tidyName (Text.pack name)) === Text.words (Text.pack name)
HS
