# expect: green
# Total lookups an agent reaches for once head and !! are banned: uncons, !?, listToMaybe,
# Map.lookupMin, with a strict Map from containers (already in the freeze file).
perl -0pi -e 's/  exposed-modules: SampleTool\n  build-depends: text \^>=(\S+)\n/  exposed-modules: SampleTool\n  build-depends:\n    containers ^>=0.8,\n    text ^>=$1,\n/' sample-tool.cabal
perl -0pi -e 's/\(banner, tidyName\)/(banner, firstAndRest, nthName, smallestKey, tidyName, topName)/; s/^(import Data.Text \(Text\))$/import Data.List (uncons, (!?))\nimport Data.Map.Strict (Map)\nimport Data.Map.Strict qualified as Map\nimport Data.Maybe (listToMaybe)\n$1/m' src/SampleTool.hs
cat >>src/SampleTool.hs <<'HS'

-- | The first name and the others, if there is one.
firstAndRest :: [Text] -> Maybe (Text, [Text])
firstAndRest = uncons

-- | The name at a position, counting from 0.
nthName :: [Text] -> Int -> Maybe Text
nthName names n = names !? n

-- | The first name, if any.
topName :: [Text] -> Maybe Text
topName = listToMaybe

-- | The smallest key and its count.
smallestKey :: Map Text Int -> Maybe (Text, Int)
smallestKey = Map.lookupMin
HS
perl -0pi -e 's/^import SampleTool \(banner, tidyName\)$/import Data.Map.Strict qualified as Map\nimport SampleTool (banner, firstAndRest, nthName, smallestKey, tidyName, topName)/m' test/SampleToolSpec.hs
perl -0pi -e 's/    QuickCheck \^>=(\S+),\n/    QuickCheck ^>=$1,\n    containers ^>=0.8,\n/' sample-tool.cabal
cat >>test/SampleToolSpec.hs <<'HS'

  describe "total lookups" $ do
    it "handle empty input" $ do
      firstAndRest [] `shouldBe` Nothing
      nthName [] 0 `shouldBe` Nothing
      topName [] `shouldBe` Nothing
      smallestKey Map.empty `shouldBe` Nothing

    it "find what is there" $ do
      firstAndRest ["a", "b"] `shouldBe` Just ("a", ["b"])
      nthName ["a", "b"] 1 `shouldBe` Just "b"
      smallestKey (Map.fromList [("b", 2), ("a", 1)]) `shouldBe` Just ("a", 1)
HS
scripts/format >/dev/null 2>&1
