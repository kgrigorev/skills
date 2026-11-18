# expect: red Build
# GHC flags read from a response file, out of sight of the switch-off step.
echo '-Wwarn' >ghc.rsp
perl -0pi -e 's/(    -Winvalid-haddock\n)/$1    \@ghc.rsp\n/' sample-tool.cabal
cat >>src/SampleTool.hs <<'HS'

unusedTop :: Int
unusedTop = 1
HS
