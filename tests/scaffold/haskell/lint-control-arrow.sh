# expect: red Lint
# Control.Arrow is banned as hard to read.
perl -0pi -e 's/\(banner, tidyName\)/(banner, both, tidyName)/; s/^(import Data.Text \(Text\))$/import Control.Arrow ((&&&))\n$1/m' src/SampleTool.hs
cat >>src/SampleTool.hs <<'HS'

-- | A value twice.
both :: Int -> (Int, Int)
both = id &&& id
HS
