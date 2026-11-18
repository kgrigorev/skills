# expect: red Build (warnings
# env: CABAL_CONFIG=relaxed-cabal-config
# A cabal user config from the environment that switches a warning off for every GHC call.
printf 'repository hackage.haskell.org\n  url: http://hackage.haskell.org/\n\nprogram-default-options\n  ghc-options: -Wno-unused-top-binds\n' >relaxed-cabal-config
cat >>src/SampleTool.hs <<'HS'

unusedTop :: Int
unusedTop = 1
HS
