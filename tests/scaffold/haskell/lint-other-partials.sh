# expect: red Lint
# Partial functions outside the default HLint rules: genericIndex, toEnum, cycle, succ.
perl -0pi -e 's/\(banner, tidyName\)/(banner, later, nth, repeatAll, tidyName, toBool)/; s/^(import Data.Text \(Text\))$/import Data.List (genericIndex)\n$1/m' src/SampleTool.hs
cat >>src/SampleTool.hs <<'HS'

-- | The nth element.
nth :: [a] -> Integer -> a
nth = genericIndex

-- | A number as a Bool.
toBool :: Int -> Bool
toBool = toEnum

-- | The list, repeated forever.
repeatAll :: [Int] -> [Int]
repeatAll = cycle

-- | The next value.
later :: Bool -> Bool
later = succ
HS
