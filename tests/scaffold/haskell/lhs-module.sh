# expect: red Haskell sources are plain .hs files
# A literate Haskell module: GHC compiles it, but Ormolu, HLint and the switch-off scan skip it.
perl -0pi -e 's/  exposed-modules: SampleTool\n/  exposed-modules:\n    SampleTool\n    Sloppy\n\n/' sample-tool.cabal
cat >src/Sloppy.lhs <<'HS'
> {-# OPTIONS_GHC -Wno-unused-top-binds -Wno-x-partial #-}
> module Sloppy (first) where
> import Data.Maybe (fromJust)
> import Debug.Trace (trace)

> first :: [Int] -> Int
> first xs = trace "x" (head xs + fromJust (Just 1))

> unusedThing :: Int
> unusedThing = undefined
HS
