# expect: red Build
# A dependency that no module uses (-Wunused-packages). containers is already in the freeze file.
perl -0pi -e 's/  exposed-modules: SampleTool\n  build-depends: text \^>=(\S+)\n/  exposed-modules: SampleTool\n  build-depends:\n    containers,\n    text ^>=$1,\n/' sample-tool.cabal
