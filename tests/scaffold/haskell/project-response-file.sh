# expect: red No switched-off checks
# cabal.project passes a response file to GHC that switches a warning off, for this package only
# ("package *" would rebuild every dependency, which cannot find the relative path).
echo '-Wno-unused-top-binds' >relax.rsp
printf '\npackage sample-tool\n  ghc-options: @relax.rsp\n' >>cabal.project
cat >>src/SampleTool.hs <<'HS'

unusedTop :: Int
unusedTop = 1
HS
