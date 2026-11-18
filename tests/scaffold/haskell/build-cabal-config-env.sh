# expect: red Build
# A cabal user config from the environment that adds -Wwarn to every GHC call.
# env: CABAL_CONFIG=relaxed-cabal-config
printf 'repository hackage.haskell.org\n  url: http://hackage.haskell.org/\n\nprogram-default-options\n  ghc-options: -Wwarn\n' >relaxed-cabal-config
cat >>src/SampleTool.hs <<'HS'

unusedTop :: Int
unusedTop = 1
HS
