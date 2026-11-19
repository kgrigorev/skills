# expect: red No switched-off checks
# expect-output: Control.Monad.ST.Unsafe (unsafeIOToST)
# A module list under "if false" claims base's Control.Monad.ST.Unsafe as one of the project's own.
perl -0pi -e 's/  exposed-modules: SampleTool\n/  exposed-modules: SampleTool\n\n  if false\n    other-modules: Control.Monad.ST.Unsafe\n/' sample-tool.cabal
grep -q 'if false' sample-tool.cabal
perl -0pi -e 's/\(banner, tidyName\)/(banner, count, tidyName)/; s/^(import Data.Text \(Text\))$/import Control.Monad.ST (runST)\nimport Control.Monad.ST.Unsafe (unsafeIOToST)\n$1/m' src/SampleTool.hs
cat >>src/SampleTool.hs <<'HS'

-- | A count computed with IO inside pure code.
count :: Int
count = runST (unsafeIOToST (length <$> readFile "/etc/hosts"))
HS
scripts/format >/dev/null 2>&1 || true
