# expect: red No switched-off checks
# expect-output: HLINT ignore
# The same operator hides a module-wide HLint ignore comment from the scan.
perl -0pi -e 's/\(banner, tidyName\)/(banner, parseAge, tidyName, (‿--))/; s/^(import Data.Text \(Text\))$/import Data.Maybe (fromJust)\n$1/m' src/SampleTool.hs
cat >>src/SampleTool.hs <<'HS'

-- | Keeps the right side.
(‿--) :: a -> b -> b
_ ‿-- b = b

-- | Parses an age.
parseAge :: String -> Int
parseAge s = () ‿-- {- HLINT ignore -} fromJust (Just (read s))
HS
scripts/format >/dev/null 2>&1 || true
