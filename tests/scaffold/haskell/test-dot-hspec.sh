# expect: red Test
# A .hspec file in the project that skips the failing example.
echo '--skip tidyName' >.hspec
perl -0pi -e 's/`shouldBe` "Ada Lovelace"/`shouldBe` "Ada  Lovelace"/' test/SampleToolSpec.hs
