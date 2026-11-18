# expect: red Haskell sources are plain .hs files
# An hsc2hs source, which the gates never read.
cat >src/Sizes.hsc <<'HS'
{-# OPTIONS_GHC -w #-}
module Sizes (size) where
size :: Int
size = head [1]
HS
