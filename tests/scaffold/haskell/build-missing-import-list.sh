# expect: red Build
# An open import (-Wmissing-import-lists).
perl -0pi -e 's/\(banner, tidyName\)/(banner, sorted, tidyName)/; s/^(import Data.Text \(Text\))$/import Data.List\n$1/m' src/SampleTool.hs
cat >>src/SampleTool.hs <<'HS'

-- | The names, sorted.
sorted :: [Text] -> [Text]
sorted = sort
HS
