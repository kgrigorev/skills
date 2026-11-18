# expect: red Lint
# Partial functions the ban list misses: NonEmpty.fromList, foldl1', digitToInt (HLint's partial group does catch maximumBy).
perl -0pi -e 's/\(banner, tidyName\)/(banner, digit, firstOf, tidyName, total)/; s/^(import Data.Text \(Text\))$/import Data.Char (digitToInt)\nimport Data.List (foldl1\x27)\nimport Data.List.NonEmpty (NonEmpty)\nimport Data.List.NonEmpty qualified as NonEmpty\n$1/m' src/SampleTool.hs
cat >>src/SampleTool.hs <<'HS'

-- | The names as a non-empty list.
firstOf :: [Text] -> NonEmpty Text
firstOf = NonEmpty.fromList

-- | The sum.
total :: [Int] -> Int
total = foldl1' (+)

-- | A digit's value.
digit :: Char -> Int
digit = digitToInt
HS
scripts/format >/dev/null 2>&1
