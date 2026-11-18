# expect: red Format
# A .cabal file that cabal-gild would format differently.
perl -0pi -e 's/  build-depends: text \^>=(\S+)\n/    build-depends:    text ^>=$1\n/' sample-tool.cabal
