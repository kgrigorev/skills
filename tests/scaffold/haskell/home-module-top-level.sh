# expect: red No switched-off checks
# expect-output: Control.Monad.ST.Unsafe (unsafeIOToST)
# An other-modules field outside every stanza, which cabal ignores.
perl -0pi -e 's/^(extra-doc-files: README.md)$/$1\nother-modules: Control.Monad.ST.Unsafe/m' sample-tool.cabal
perl -0pi -e 's/\(banner, tidyName\)/(banner, count, tidyName)/; s/^(import Data.Text \(Text\))$/import Control.Monad.ST (runST)\nimport Control.Monad.ST.Unsafe (unsafeIOToST)\n$1/m' src/SampleTool.hs
cat >>src/SampleTool.hs <<'HS'

-- | A count computed with IO inside pure code.
count :: Int
count = runST (unsafeIOToST (length <$> readFile "/etc/hosts"))
HS
scripts/format >/dev/null 2>&1 || true
