# expect: red No switched-off checks
# -w (all warnings off), quoted, in cabal.project. cabal-gild would unquote it in the .cabal file,
# but nothing formats cabal.project.
printf '\npackage *\n  ghc-options: "-w"\n' >>cabal.project
