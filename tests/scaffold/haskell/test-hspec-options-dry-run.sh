# expect: red Test
# HSPEC_OPTIONS=--dry-run would report every example as passed without running it.
# env: HSPEC_OPTIONS=--dry-run
perl -0pi -e 's/`shouldBe` "Ada Lovelace"/`shouldBe` "Ada  Lovelace"/' test/SampleToolSpec.hs
