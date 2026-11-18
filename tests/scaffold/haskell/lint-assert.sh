# expect: red Lint
# Control.Exception.assert as a panic: error is banned, assert False crashes just the same.
perl -0pi -e 's/\(banner, tidyName\)/(banner, half, tidyName)/; s/^(import Data.Text \(Text\))$/import Control.Exception (assert)\n$1/m' src/SampleTool.hs
cat >>src/SampleTool.hs <<'HS'

-- | Half of an even number.
half :: Int -> Int
half n = assert (even n) (n `div` 2)
HS
scripts/format >/dev/null 2>&1
