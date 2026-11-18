# expect: red No switched-off checks
# -Wnot turns every warning off.
perl -0pi -e 's/(    -Winvalid-haddock\n)/$1    -Wnot\n/' sample-tool.cabal
cat >>src/SampleTool.hs <<'HS'

unusedTop :: Int
unusedTop = 1
HS
