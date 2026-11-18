# expect: red No switched-off checks
# cabal.project imports a file that no gate reads.
printf '\nimport: relaxed.config\n' >>cabal.project
printf 'package sample-tool\n  ghc-options: -Wwarn\n' >relaxed.config
cat >>src/SampleTool.hs <<'HS'

unusedTop :: Int
unusedTop = 1
HS
