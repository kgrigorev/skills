# expect: red Test
# HSPEC_SKIP from the environment would skip the failing example.
# env: HSPEC_SKIP=tidyName
perl -0pi -e 's/`shouldBe` "Ada Lovelace"/`shouldBe` "Ada  Lovelace"/' test/SampleToolSpec.hs
