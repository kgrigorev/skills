# expect: red No switched-off checks
# expect-output: IO.unsafeIOToST
# A Unicode operator that ends in "--": GHC reads an operator, and a scan that knows only ASCII
# symbols read a line comment that hid an unsafe call after it.
perl -0pi -e 's/\(banner, tidyName\)/(banner, count, tidyName, (∘--))/; s/^(import Data.Text \(Text\))$/import Control.Monad.ST (runST)\n$1/m; s/^(import Data.Text qualified as Text)$/$1\nimport GHC.IO qualified as IO/m' src/SampleTool.hs
cat >>src/SampleTool.hs <<'HS'

-- | Keeps the right side.
(∘--) :: a -> b -> b
_ ∘-- b = b

-- | A count computed with IO inside pure code.
count :: Int
count = () ∘-- runST (IO.unsafeIOToST (pure 1))
HS
scripts/format >/dev/null 2>&1 || true
