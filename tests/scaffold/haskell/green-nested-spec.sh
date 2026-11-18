# expect: green
# A new test file in a subfolder, which hspec-discover finds by its name.
perl -0pi -e 's/  other-modules: SampleToolSpec\n/  other-modules:\n    SampleTool.TidyNameSpec\n    SampleToolSpec\n\n/' sample-tool.cabal
mkdir -p test/SampleTool
cat >test/SampleTool/TidyNameSpec.hs <<'HS'
-- | More tests for tidyName: tabs and newlines count as spaces.
module SampleTool.TidyNameSpec (spec) where

import SampleTool (tidyName)
import Test.Hspec (Spec, describe, it, shouldBe)

-- | The tests.
spec :: Spec
spec = describe "tidyName" $ do
  it "treats a tab as a space" $
    tidyName "Ada\tLovelace" `shouldBe` "Ada Lovelace"

  it "treats a newline as a space" $
    tidyName "Ada\nLovelace" `shouldBe` "Ada Lovelace"
HS
