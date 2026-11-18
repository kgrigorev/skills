# expect: red Lint
# error is banned, so a home-made exception type is thrown from pure code: the same crash.
# (throw (ErrorCall ..) would be caught by HLint's "Use error" hint alone.)
perl -0pi -e 's/\(banner, tidyName\)/(OddNumber (..), banner, half, tidyName)/; s/^(import Data.Text \(Text\))$/import Control.Exception (Exception, throw)\n$1/m' src/SampleTool.hs
cat >>src/SampleTool.hs <<'HS'

-- | Thrown for an odd number.
data OddNumber = OddNumber
  deriving stock (Show)

instance Exception OddNumber

-- | Half of an even number.
half :: Int -> Int
half n = if even n then n `div` 2 else throw OddNumber
HS
scripts/format >/dev/null 2>&1
