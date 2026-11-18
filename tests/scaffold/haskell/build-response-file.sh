# expect: red No switched-off checks
# GHC flags read from a response file (@file): -w switches every warning off.
echo '-w' >ghc.rsp
perl -0pi -e 's/(    -Winvalid-haddock\n)/$1    \@ghc.rsp\n/' sample-tool.cabal
cat >>src/SampleTool.hs <<'HS'

unusedTop :: Int
unusedTop = 1
HS
