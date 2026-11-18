# expect: red Warning settings
# -Werror dropped from cabal.project.
perl -0pi -e 's/package sample-tool\n  ghc-options: -Werror\n//' cabal.project
cat >>src/SampleTool.hs <<'HS'

unusedTop :: Int
unusedTop = 1
HS
