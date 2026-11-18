# expect: red No switched-off checks
# The old -fno-warn form.
perl -0pi -e 's/(  exposed-modules: SampleTool\n)/$1  ghc-options: -fno-warn-unused-binds\n/' sample-tool.cabal
