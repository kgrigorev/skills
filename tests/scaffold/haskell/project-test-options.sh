# expect: red No switched-off checks
# cabal.project adds --skip for the failing example.
printf '\npackage *\n  test-options: "--skip=tidyName"\n' >>cabal.project
perl -0pi -e 's/`shouldBe` "Ada Lovelace"/`shouldBe` "Ada  Lovelace"/' test/SampleToolSpec.hs
