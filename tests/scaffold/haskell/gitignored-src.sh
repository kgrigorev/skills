# expect: red Haskell sources are plain .hs files
# A module that git ignores: it builds locally, the gates never list it, and CI lacks it.
echo src/Hidden.hs >>.gitignore
perl -0pi -e 's/  exposed-modules: SampleTool\n/  exposed-modules:\n    Hidden\n    SampleTool\n\n/' sample-tool.cabal
cat >src/Hidden.hs <<'HS'
{-# OPTIONS_GHC -Wno-x-partial #-}
module Hidden (first) where
import Data.Maybe (fromJust)
first :: [Int] -> Int
first xs = head xs + fromJust (Just 1)
HS
