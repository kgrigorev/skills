# expect: red No switched-off checks
# expect-output: HLINT ignore
# A non-ASCII character literal: read as bytes, 'λ' made the scan pair the quotes wrongly, so
# the '"' after it opened a string that hid a module-wide HLint ignore comment.
perl -0pi -e 's/\(banner, tidyName\)/(banner, larger, parseAge, tidyName)/; s/^(import Data.Text \(Text\))$/import Data.Maybe (fromJust)\n$1/m' src/SampleTool.hs
cat >>src/SampleTool.hs <<'HS'

-- | The larger of two characters.
larger :: Char
larger = max 'λ' '"' {- HLINT ignore -}

-- | An age.
parseAge :: String -> Int
parseAge s = fromJust (Just (read s)) + undefined
HS
scripts/format >/dev/null 2>&1 || true
