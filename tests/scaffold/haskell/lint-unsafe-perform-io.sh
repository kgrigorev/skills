# expect: red Lint
# IO inside pure code.
perl -0pi -e 's/\(banner, tidyName\)/(banner, sneaky, tidyName)/; s/^(import Data.Text qualified as Text)$/$1\nimport System.IO.Unsafe (unsafePerformIO)/m' src/SampleTool.hs
cat >>src/SampleTool.hs <<'HS'

-- | A pure value read from IO.
sneaky :: Int
sneaky = unsafePerformIO (pure 1)
HS
