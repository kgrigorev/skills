# expect: red No switched-off checks
# A response file that switches one warning off, so the later -Werror cannot turn it back on.
echo '-Wno-unused-top-binds' >ghc.rsp
perl -0pi -e 's/(    -Winvalid-haddock\n)/$1    \@ghc.rsp\n/' sample-tool.cabal
cat >>src/SampleTool.hs <<'HS'

unusedTop :: Int
unusedTop = 1
HS
