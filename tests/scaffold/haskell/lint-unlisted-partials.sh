# expect: red Lint
# Partial functions the ban list does not name: Map.findMin, Map.elemAt, Text.index, chr.
perl -0pi -e 's/  exposed-modules: SampleTool\n  build-depends: text \^>=(\S+)\n/  exposed-modules: SampleTool\n  build-depends:\n    containers ^>=0.8,\n    text ^>=$1,\n/' sample-tool.cabal
perl -0pi -e 's/\(banner, tidyName\)/(banner, firstLetter, letter, smallest, third, tidyName)/; s/^(import Data.Text \(Text\))$/import Data.Char (chr)\nimport Data.Map.Strict (Map)\nimport Data.Map.Strict qualified as Map\n$1/m' src/SampleTool.hs
cat >>src/SampleTool.hs <<'HS'

-- | The smallest key.
smallest :: Map Text Int -> Text
smallest counts = fst (Map.findMin counts)

-- | The third entry.
third :: Map Text Int -> (Text, Int)
third = Map.elemAt 2

-- | The first letter.
firstLetter :: Text -> Char
firstLetter name = Text.index name 0

-- | A code point as a character.
letter :: Int -> Char
letter = chr
HS
