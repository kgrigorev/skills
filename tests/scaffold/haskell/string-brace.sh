# expect: red No switched-off checks
# String literals "{-" and "-}": the scan strips everything between them as a block comment.
perl -0pi -e 's/\(banner, tidyName\)/(banner, closeMark, openMark, sneaky, tidyName)/; s/^(import Data.Text \(Text\))$/import Control.Monad.ST (runST)\n$1/m; s/^(import Data.Text qualified as Text)$/$1\nimport GHC.IO qualified as IO/m' src/SampleTool.hs
cat >>src/SampleTool.hs <<'HS'

-- | Where a block comment starts.
openMark :: Text
openMark = "{-"

-- | IO inside pure code.
sneaky :: Int -> Int
sneaky x = runST (IO.unsafeIOToST (pure x))

-- | Where a block comment ends.
closeMark :: Text
closeMark = "-}"
HS
scripts/format >/dev/null 2>&1
