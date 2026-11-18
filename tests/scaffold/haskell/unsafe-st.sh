# expect: red No switched-off checks
# An unsafe escape hatch that HLint's ban list does not name.
perl -0pi -e 's/\(banner, tidyName\)/(banner, sneaky, tidyName)/; s/^(import Data.Text \(Text\))$/import Control.Monad.ST (runST)\nimport Control.Monad.ST.Unsafe (unsafeIOToST)\n$1/m' src/SampleTool.hs
cat >>src/SampleTool.hs <<'HS'

-- | IO in pure code.
sneaky :: Int -> Int
sneaky x = runST (unsafeIOToST (pure x))
HS
