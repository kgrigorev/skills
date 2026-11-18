# expect: red Warning settings
# A new executable without import: common builds without the warning flags.
printf '\nexecutable extra\n  hs-source-dirs: tools\n  main-is: Main.hs\n  default-language: GHC2024\n  build-depends: base\n' >>sample-tool.cabal
mkdir tools
cat >tools/Main.hs <<'HS'
-- | Extra.
module Main (main) where

import Data.List

-- | Main.
main :: IO ()
main = print (sort [3, 1, 2 :: Int])
  where
    unused = 1
HS
