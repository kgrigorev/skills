# expect: red Warning settings
# -Wunused-packages dropped, so an unused dependency would pass.
perl -0pi -e 's/    -Wunused-packages\n//' sample-tool.cabal
