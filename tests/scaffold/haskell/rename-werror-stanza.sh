# expect: red Warning settings
# The -Werror stanza names another package, so it applies to nothing.
perl -0pi -e 's/^package sample-tool$/package sample-tool-old/m' cabal.project
cat >>src/SampleTool.hs <<'HS'

unusedTop :: Int
unusedTop = 1
HS
