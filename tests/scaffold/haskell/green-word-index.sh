# expect: green
# A new module with a strict Map, a record, foldl', Either errors, and tests with a custom generator.
perl -0pi -e 's/  exposed-modules: SampleTool\n  build-depends: text \^>=(\S+)\n/  exposed-modules:\n    SampleTool\n    SampleTool.Index\n\n  build-depends:\n    containers ^>=0.8,\n    text ^>=$1,\n/; s/  other-modules: SampleToolSpec\n/  other-modules:\n    SampleTool.IndexSpec\n    SampleToolSpec\n\n/' sample-tool.cabal
mkdir -p src/SampleTool test/SampleTool
cat >src/SampleTool/Index.hs <<'HS'
-- | An index from words to the lines they appear on.
module SampleTool.Index
  ( Index (..),
    IndexError (..),
    build,
    lookupWord,
  )
where

import Data.Map.Strict (Map)
import Data.Map.Strict qualified as Map
import Data.Text (Text)
import Data.Text qualified as Text

-- | Words and the line numbers they appear on, in order.
newtype Index = Index {entries :: Map Text [Int]}
  deriving stock (Eq, Show)

-- | Why a lookup failed.
data IndexError
  = EmptyWord
  | NotFound Text
  deriving stock (Eq, Show)

-- | Builds the index of a text, one entry per word and line.
build :: Text -> Index
build text = Index (Map.map reverse (foldl' add Map.empty numbered))
  where
    numbered = zip [1 ..] (Text.lines text)
    add acc (n, line) = foldl' (\m word -> Map.insertWith (<>) (Text.toLower word) [n] m) acc (Text.words line)

-- | The lines a word appears on.
lookupWord :: Text -> Index -> Either IndexError [Int]
lookupWord word (Index m)
  | Text.null (Text.strip word) = Left EmptyWord
  | otherwise = maybe (Left (NotFound word)) Right (Map.lookup (Text.toLower word) m)
HS
cat >test/SampleTool/IndexSpec.hs <<'HS'
-- | Tests for SampleTool.Index.
module SampleTool.IndexSpec (spec) where

import Data.Text qualified as Text
import SampleTool.Index (IndexError (EmptyWord, NotFound), build, lookupWord)
import Test.Hspec (Spec, context, describe, it, shouldBe)
import Test.Hspec.QuickCheck (prop)
import Test.QuickCheck (Gen, elements, forAll, listOf1, (===))

-- | Short lower-case words.
word :: Gen String
word = listOf1 (elements "abc")

-- | The tests.
spec :: Spec
spec = describe "lookupWord" $ do
  context "with a known word" $
    it "returns its lines in order" $
      lookupWord "Ada" (build "ada\nbob\nAda ada") `shouldBe` Right [1, 3, 3]

  it "rejects a blank word" $
    lookupWord "  " (build "ada") `shouldBe` Left EmptyWord

  it "reports a missing word" $
    lookupWord "eve" (build "ada") `shouldBe` Left (NotFound "eve")

  prop "finds every word on the first line" $
    forAll word $ \w ->
      lookupWord (Text.pack w) (build (Text.pack w)) === Right [1]
HS
# An agent formats before it checks.
scripts/format >/dev/null 2>&1
