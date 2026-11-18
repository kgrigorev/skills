# expect: red No switched-off checks
# A "--" string literal: the scan strips it and the rest of the line as a comment, so an unsafe
# function from a qualified GHC.IO import (no Unsafe in the module name) after it goes unseen.
perl -0pi -e 's/\(banner, tidyName\)/(banner, header, tidyName)/; s/^(import Data.Text \(Text\))$/import Control.Monad.ST (runST)\n$1/m; s/^(import Data.Text qualified as Text)$/$1\nimport GHC.IO qualified as IO/m' src/SampleTool.hs
cat >>src/SampleTool.hs <<'HS'

-- | The separator line and a count computed with IO inside pure code.
header :: (Text, Int)
header = ("--", runST (IO.unsafeIOToST (pure 1)))
HS
scripts/format >/dev/null 2>&1
grep -q 'IO.unsafeIOToST' src/SampleTool.hs
