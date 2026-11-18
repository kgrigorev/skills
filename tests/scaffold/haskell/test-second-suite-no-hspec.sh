# expect: red Build settings
# A second test suite whose Main does not run hspec.
printf '\ntest-suite smoke\n  import: common\n  type: exitcode-stdio-1.0\n  hs-source-dirs: smoke\n  main-is: Main.hs\n' >>sample-tool.cabal
mkdir smoke
printf -- '-- | Smoke test.\nmodule Main (main) where\n\n-- | Passes without checking anything.\nmain :: IO ()\nmain = pure ()\n' >smoke/Main.hs
