# expect: red Warning settings
# -Wall dropped from the common stanza.
perl -0pi -e 's/    -Wall\n//' sample-tool.cabal
cat >>src/SampleTool.hs <<'HS'

unusedTop :: Int
unusedTop = 1
HS
