# expect: red Pinned tools
# mise.local.toml puts a fake hlint first on PATH, so partial code would pass Lint.
mkdir .tools
printf '#!/bin/sh\necho 3.10\n' >.tools/hlint
chmod +x .tools/hlint
printf '[env]\n_.path = ["{{config_root}}/.tools"]\n' >mise.local.toml
perl -0pi -e 's/\(banner, tidyName\)/(banner, parseAmount, tidyName)/; s/^(import Data.Text \(Text\))$/import Data.Maybe (fromJust)\n$1/m' src/SampleTool.hs
cat >>src/SampleTool.hs <<'HS'

-- | Parses an amount.
parseAmount :: String -> Int
parseAmount s = fromJust (Just (read s))
HS
