# expect: red Build settings
# The test suite marked unbuildable.
perl -0pi -e 's/(test-suite sample-tool-test\n  import: common\n)/$1  buildable: False\n/' sample-tool.cabal
