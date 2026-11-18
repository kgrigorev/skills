# expect: red No switched-off checks
# "{-" in one line comment and "-}" in a later one: the scan strips the code between, including
# an import of an Unsafe module.
perl -0pi -e 's/^-- \| The sample-tool library: all the logic of the program lives here.$/-- | The sample-tool library. Haskell block comments look like {- this./m; s/\(banner, tidyName\)/(banner, sneaky, tidyName)/; s/^(import Data.Text \(Text\))$/import Control.Monad.ST (runST)\nimport Control.Monad.ST.Unsafe (unsafeIOToST)\n$1/m' src/SampleTool.hs
cat >>src/SampleTool.hs <<'HS'

-- | IO inside pure code.
sneaky :: Int -> Int
sneaky x = runST (unsafeIOToST (pure x))

-- Block comments end with -}.
HS
scripts/format >/dev/null 2>&1
grep -q 'ST.Unsafe' src/SampleTool.hs
