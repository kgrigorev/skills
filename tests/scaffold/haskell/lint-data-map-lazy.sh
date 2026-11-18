# expect: red Lint
# The lazy Data.Map, where Data.Map.Strict is the rule.
perl -0pi -e 's/\(banner, tidyName\)/(banner, emptyIndex, tidyName)/; s/^(import Data.Text \(Text\))$/import Data.Map (Map)\nimport Data.Map qualified as Map\n$1/m' src/SampleTool.hs
cat >>src/SampleTool.hs <<'HS'

-- | No names yet.
emptyIndex :: Map Text Int
emptyIndex = Map.empty
HS
