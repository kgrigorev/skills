# expect: red Lint
# fromJust and read fail on some inputs.
perl -0pi -e 's/\(banner, tidyName\)/(banner, parseAmount, tidyName)/; s/^(import Data.Text \(Text\))$/import Data.Maybe (fromJust)\n$1/m' src/SampleTool.hs
cat >>src/SampleTool.hs <<'HS'

-- | Parses an amount.
parseAmount :: String -> Int
parseAmount s = fromJust (Just (read s))
HS
