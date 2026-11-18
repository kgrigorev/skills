# expect: red No switched-off checks
# A warning switched off in a new component's source file.
mkdir bench
cat >bench/Main.hs <<'HS'
{-# OPTIONS_GHC -Wno-unused-imports #-}

-- | Bench.
module Main (main) where

-- | Runs.
main :: IO ()
main = pure ()
HS
