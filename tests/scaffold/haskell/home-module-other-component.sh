# expect: red No switched-off checks
# expect-output: Control.Monad.ST.Unsafe (unsafeIOToST)
# Another component has its own module named Control.Monad.ST.Unsafe. GHC resolves module
# names per component, so the library still imports base's module.
cat >>sample-tool.cabal <<'CABAL'

executable sample-tool-demo
  import: common
  hs-source-dirs: demo
  main-is: Main.hs
  other-modules: Control.Monad.ST.Unsafe
CABAL
mkdir -p demo/Control/Monad/ST
printf -- '-- | A demo.\nmodule Main (main) where\n\n-- | Runs the demo.\nmain :: IO ()\nmain = putStrLn "demo"\n' > demo/Main.hs
printf -- '-- | Helpers for the demo.\nmodule Control.Monad.ST.Unsafe () where\n' > demo/Control/Monad/ST/Unsafe.hs
perl -0pi -e 's/\(banner, tidyName\)/(banner, count, tidyName)/; s/^(import Data.Text \(Text\))$/import Control.Monad.ST (runST)\nimport Control.Monad.ST.Unsafe (unsafeIOToST)\n$1/m' src/SampleTool.hs
cat >>src/SampleTool.hs <<'HS'

-- | A count computed with IO inside pure code.
count :: Int
count = runST (unsafeIOToST (length <$> readFile "/etc/hosts"))
HS
scripts/format >/dev/null 2>&1 || true
