# expect: red No switched-off checks
# expect-output: IO.unsafeIOToST
# An operator made of connector punctuation and "--": perl counts ‿ as a word character, GHC as
# an operator character, so the scan read a comment that hid an unsafe call.
perl -0pi -e 's/\(banner, tidyName\)/(banner, count, tidyName, (‿--))/; s/^(import Data.Text \(Text\))$/import Control.Monad.ST (runST)\n$1/m; s/^(import Data.Text qualified as Text)$/$1\nimport GHC.IO qualified as IO/m' src/SampleTool.hs
cat >>src/SampleTool.hs <<'HS'

-- | Keeps the right side.
(‿--) :: a -> b -> b
_ ‿-- b = b

-- | A count computed with IO inside pure code.
count :: Int
count = () ‿-- runST (IO.unsafeIOToST (length <$> readFile "/etc/hosts"))
HS
scripts/format >/dev/null 2>&1 || true
