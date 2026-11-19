# expect: red No switched-off checks
# A multi-line HLint ignore-all comment hides trace, undefined, fromJust and read.
perl -0pi -e 's/\(banner, tidyName\)/(banner, parseAmount, tidyName)/; s/^(import Data.Text \(Text\))$/import Data.Maybe (fromJust)\n$1/m; s/^(import Data.Text qualified as Text)$/$1\nimport Debug.Trace (trace)/m' src/SampleTool.hs
cat >>src/SampleTool.hs <<'HS'

{-
HLINT ignore
-}

-- | Parses an amount.
parseAmount :: String -> Int
parseAmount s = trace "debug" (if null s then undefined else fromJust (Just (read s)))
HS
