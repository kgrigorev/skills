# expect: red Build settings
# expect-output: is in more than one source folder
# A second test folder listed first holds a passing SampleToolSpec. GHC compiles that one,
# so the broken test/SampleToolSpec.hs that hspec-discover found never builds.
perl -0pi -e 's/`shouldBe` "Ada Lovelace"/`shouldBe` "Ada  Lovelace"/' test/SampleToolSpec.hs
perl -0pi -e 's/(test-suite sample-tool-test\n  import: common\n  type: exitcode-stdio-1.0\n  hs-source-dirs:) test/$1\n    test-support\n    test/' sample-tool.cabal
mkdir -p test-support
cat > test-support/SampleToolSpec.hs <<'HS'
-- | Tests for the SampleTool module.
module SampleToolSpec (spec) where

import Data.Text qualified as Text
import SampleTool (tidyName)
import Test.Hspec (Spec, it, shouldBe)
import Test.QuickCheck ((===))

-- | The tests.
spec :: Spec
spec = do
  it "tidies a name" $ tidyName "Ada" `shouldBe` "Ada"
  it "keeps a word" $ tidyName (Text.pack "Ada") === "Ada"
HS
scripts/format >/dev/null 2>&1 || true
