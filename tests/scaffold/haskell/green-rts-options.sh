# expect: green
# An executable built with the threaded runtime and default RTS options, as servers often are.
perl -0pi -e 's/(executable sample-tool\n  import: common\n)/$1  ghc-options:\n    -threaded\n    -rtsopts\n    "-with-rtsopts=-N -A16m"\n\n/' sample-tool.cabal
grep -q threaded sample-tool.cabal
scripts/format >/dev/null 2>&1
