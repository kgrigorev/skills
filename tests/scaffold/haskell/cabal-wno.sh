# expect: red No switched-off checks
# A warning switched off in one component's ghc-options.
perl -0pi -e 's/(  exposed-modules: SampleTool\n)/$1  ghc-options: -Wno-unused-top-binds\n/' sample-tool.cabal
cat >>src/SampleTool.hs <<'HS'

unusedTop :: Int
unusedTop = 1
HS
