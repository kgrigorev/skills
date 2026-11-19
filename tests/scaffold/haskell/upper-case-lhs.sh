# expect: red Haskell sources are plain .hs files
# expect-output: src/Hidden.LHS
# A literate source with an upper-case extension, which the .lhs rule missed on macOS.
perl -0pi -e 's/  exposed-modules: SampleTool\n/  exposed-modules:\n    Hidden\n    SampleTool\n/' sample-tool.cabal
cat > src/Hidden.LHS <<'HS'
> {-# OPTIONS_GHC -w #-}
> module Hidden where
> import System.IO.Unsafe (unsafePerformIO)
> import Data.Maybe
> x = fromJust (Just (unsafePerformIO (pure (1 :: Int))))
> unused = ()
HS
scripts/format >/dev/null 2>&1 || true
