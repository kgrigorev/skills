# expect: red No switched-off checks
# expect-output: names and operators must be ASCII
# An operator of U+2FFC and "--": GHC knows the symbol from Unicode 15.1, perl reads an
# unassigned character and then a comment that hid an unsafe call.
perl -CSD -0pi -e 's/\(banner, tidyName\)/(banner, count, tidyName, (\x{2FFC}--))/; s/^(import Data.Text \(Text\))$/import Control.Monad.ST (runST)\n$1/m; s/^(import Data.Text qualified as Text)$/$1\nimport GHC.IO qualified as IO/m' src/SampleTool.hs
cat >>src/SampleTool.hs <<'HS'

-- | Keeps the right side.
(@@--) :: a -> b -> b
_ @@-- b = b

-- | A count computed with IO inside pure code.
count :: Int
count = () @@-- runST (IO.unsafeIOToST (length <$> readFile "/etc/hosts"))
HS
perl -CSD -pi -e 's/\@\@/\x{2FFC}/g' src/SampleTool.hs
scripts/format >/dev/null 2>&1 || true
