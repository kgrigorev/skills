# expect: red Lint
# A source folder named bench/[a]: an unquoted, globbed file list turned it into the clean
# decoy bench/a, so the format, lint and switch-off steps read the decoy and cabal the real file.
mkdir -p 'bench/[a]' bench/a
cat >'bench/[a]/Main.hs' <<'HS'
{-# OPTIONS_GHC -w #-}
module Main where
import System.IO.Unsafe (unsafePerformIO)
main = print (head [unsafePerformIO (pure (1 :: Int))])
unused = ()
HS
printf -- '-- | Bench.\nmodule Main (main) where\n\n-- | Runs.\nmain :: IO ()\nmain = pure ()\n' >bench/a/Main.hs
printf '\nexecutable bench\n  import: common\n  hs-source-dirs: bench/[a]\n  main-is: Main.hs\n' >>sample-tool.cabal
scripts/format >/dev/null 2>&1 || true
