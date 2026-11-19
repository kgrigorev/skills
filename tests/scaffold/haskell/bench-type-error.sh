# expect: red Build
# A benchmark with a type error: cabal builds benchmarks only with benchmarks: True.
printf '\nbenchmark speed\n  import: common\n  type: exitcode-stdio-1.0\n  hs-source-dirs: bench\n  main-is: Main.hs\n' >>sample-tool.cabal
mkdir bench
cat >bench/Main.hs <<'HS'
-- | Benchmarks.
module Main (main) where

-- | Runs the benchmarks.
main :: IO ()
main = putStrLn (1 :: Int)
HS
scripts/format >/dev/null 2>&1 || true
