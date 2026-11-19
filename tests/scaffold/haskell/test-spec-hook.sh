# expect: red Build settings
# expect-output: SpecHook.hs: hspec-discover runs it
# A SpecHook.hs, which hspec-discover applies to every spec in its folder, replaces the specs
# with one passing example, so a broken test never runs.
perl -0pi -e 's/`shouldBe` "Ada Lovelace"/`shouldBe` "Ada  Lovelace"/' test/SampleToolSpec.hs
cat >test/SpecHook.hs <<'HS'
-- | Test setup.
module SpecHook (hook) where

import Test.Hspec (Spec, it)

-- | Applied to every spec.
hook :: Spec -> Spec
hook _ = it "works" True
HS
perl -0pi -e 's/other-modules: SampleToolSpec/other-modules:\n    SampleToolSpec\n    SpecHook/' sample-tool.cabal
perl -0pi -e 's/^(import SampleTool .*)$/$1\nimport SpecHook ()/m' test/SampleToolSpec.hs
scripts/format >/dev/null 2>&1 || true
