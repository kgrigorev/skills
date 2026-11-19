# expect: red Haskell sources are plain .hs files
# expect-output: src/Hidden.HS
# GHC finds src/Hidden.HS on a macOS disk, and a case-sensitive file list skipped it.
perl -0pi -e 's/  exposed-modules: SampleTool\n/  exposed-modules:\n    Hidden\n    SampleTool\n/' sample-tool.cabal
cat > src/Hidden.HS <<'HS'
{-# OPTIONS_GHC -w #-}
{- HLINT ignore -}
module Hidden where
import System.IO.Unsafe
import Data.Maybe
x = fromJust (Just (unsafePerformIO (pure 1)))
unused = ()
HS
scripts/format >/dev/null 2>&1 || true
