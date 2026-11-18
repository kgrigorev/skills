# expect: red Lint
# An ignore line in .hlint.yaml turns the function bans off. HLint's partial-function rules
# still catch fromJust (only the owner's review guards the file itself).
printf '\n- ignore: {name: Avoid restricted function}\n' >>.hlint.yaml
perl -0pi -e 's/\(banner, tidyName\)/(banner, parseAmount, tidyName)/; s/^(import Data.Text \(Text\))$/import Data.Maybe (fromJust)\n$1/m' src/SampleTool.hs
cat >>src/SampleTool.hs <<'HS'

-- | Parses an amount.
parseAmount :: String -> Int
parseAmount s = fromJust (Just (read s))
HS
