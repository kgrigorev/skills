# expect: green
# A test helper module that is not a spec: a generator that the spec module imports.
perl -0pi -e 's/  other-modules: SampleToolSpec\n/  other-modules:\n    Generators\n    SampleToolSpec\n\n/' sample-tool.cabal
cat >test/Generators.hs <<'HS'
-- | Generators for the tests.
module Generators (spacedName) where

import Test.QuickCheck (Gen, elements, listOf)

-- | Names made of letters and runs of spaces.
spacedName :: Gen String
spacedName = listOf (elements "ab  ")
HS
perl -0pi -e 's/^(import Test.Hspec \(.*\))$/import Generators (spacedName)\n$1/m; s/import Test.QuickCheck \(\(===\)\)/import Test.QuickCheck (forAll, (===))/' test/SampleToolSpec.hs
cat >>test/SampleToolSpec.hs <<'HS'

    prop "never leaves two spaces in a row"
      $ forAll spacedName
      $ \name -> not ("  " `Text.isInfixOf` tidyName (Text.pack name))
HS
scripts/format >/dev/null 2>&1
