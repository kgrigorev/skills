# expect: red No switched-off checks
# expect-output: Ä.unsafeIOToST
# An unsafe function through a qualifier that starts with a non-ASCII capital letter.
perl -0pi -e 's/\(banner, tidyName\)/(banner, count, tidyName)/; s/^(import Data.Text \(Text\))$/import Control.Monad.ST (runST)\n$1/m; s/^(import Data.Text qualified as Text)$/$1\nimport GHC.IO qualified as \x{c3}\x{84}/m' src/SampleTool.hs
cat >>src/SampleTool.hs <<'HS2'

-- | A count computed with IO inside pure code.
count :: Int
count = runST (Ä.unsafeIOToST (pure 1))
HS2
scripts/format >/dev/null 2>&1 || true
