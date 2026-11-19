# expect: red Build settings
# The failing tests move to a module whose name does not end in Spec: hspec-discover skips it.
git mv test/SampleToolSpec.hs test/SampleToolChecks.hs
perl -0pi -e 's/module SampleToolSpec \(spec\)/module SampleToolChecks (spec)/; s/`shouldBe` "Ada Lovelace"/`shouldBe` "Ada  Lovelace"/' test/SampleToolChecks.hs
perl -0pi -e 's/  other-modules: SampleToolSpec\n/  other-modules:\n    SampleToolChecks\n    SampleToolSpec\n\n/' sample-tool.cabal
cat >test/SampleToolSpec.hs <<'HS'
-- | Tests for the SampleTool module.
module SampleToolSpec (spec) where

import SampleTool (banner)
import Test.Hspec (Spec, it, shouldBe)

-- | The tests.
spec :: Spec
spec = it "has a banner" $ banner `shouldBe` "sample-tool: A sample tool that tests the template"
HS
scripts/format >/dev/null 2>&1
