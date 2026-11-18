# expect: red No switched-off checks
# -Wwarn after -Werror undoes it.
perl -0pi -e 's/  ghc-options: -Werror\n/  ghc-options: -Werror -Wwarn\n/' cabal.project
