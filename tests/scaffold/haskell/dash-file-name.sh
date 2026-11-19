# expect: red Lint
# expect-output: Partial. Use readMaybe from Text.Read.
# A root file named -o-optP.hs: passed without ./, HLint read it as --only and checked nothing.
printf -- '-- | Notes.\nmodule Notes () where\n' > ./-o-optP.hs
perl -0pi -e 's/\(banner, tidyName\)/(banner, parseAge, tidyName)/; s/^(import Data.Text \(Text\))$/import Data.Maybe (fromJust)\n$1/m' src/SampleTool.hs
cat >>src/SampleTool.hs <<'HS'

-- | Parses an age.
parseAge :: String -> Int
parseAge s = fromJust (Just (read s))
HS
scripts/format >/dev/null 2>&1 || true
