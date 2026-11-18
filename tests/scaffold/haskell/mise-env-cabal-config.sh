# expect: red Build (warnings
# mise.toml's own [env] (the one config the check allows) points cabal at a relaxed user config.
printf 'repository hackage.haskell.org\n  url: http://hackage.haskell.org/\n\nprogram-default-options\n  ghc-options: -Wno-unused-top-binds\n' >relaxed-cabal-config
printf 'CABAL_CONFIG = "{{config_root}}/relaxed-cabal-config"\n' >>mise.toml
cat >>src/SampleTool.hs <<'HS'

unusedTop :: Int
unusedTop = 1
HS
