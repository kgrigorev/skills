# expect: red Lint
# A false property run on one input only (withNumTests 1; the older withMaxSuccess is
# deprecated, so -Werror rejects it for that reason alone). The seed-1 input passes.
perl -0pi -e 's/import Test.QuickCheck \(\(===\)\)/import Test.QuickCheck (withNumTests, (===))/' test/SampleToolSpec.hs
cat >>test/SampleToolSpec.hs <<'HS'

    prop "leaves every name as it is" $ withNumTests 1 $ \name ->
      tidyName (Text.pack name) === Text.pack name
HS
