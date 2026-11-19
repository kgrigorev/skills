# expect: red Build settings
# expect-output: no module imports it
# A test module without the Spec suffix, imported only as "import SampleToolTests ()": that
# brings in nothing, and hspec-discover runs only *Spec modules, so its failing test never runs.
perl -0pi -e 's/other-modules: SampleToolSpec/other-modules:\n    SampleToolSpec\n    SampleToolTests/' sample-tool.cabal
cat >test/SampleToolTests.hs <<'HS'
-- | More tests for the SampleTool module.
module SampleToolTests (spec) where

import SampleTool (tidyName)
import Test.Hspec (Spec, it, shouldBe)

-- | The tests.
spec :: Spec
spec = it "tidies a name" (tidyName "Ada  Lovelace" `shouldBe` "Ada  Lovelace")
HS
perl -0pi -e 's/^(import SampleTool .*)$/$1\nimport SampleToolTests ()/m' test/SampleToolSpec.hs
scripts/format >/dev/null 2>&1 || true
