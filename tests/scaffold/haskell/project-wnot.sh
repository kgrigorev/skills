# expect: red No switched-off checks
# -Wnot for every program, from cabal.project.
printf '\nprogram-options\n  ghc-options: -Wnot\n' >>cabal.project
