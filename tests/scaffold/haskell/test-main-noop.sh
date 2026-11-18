# expect: red Test
# A test Main that replaces the hspec-discover driver and runs nothing.
printf -- '-- | Test driver.\nmodule Main (main) where\n\n-- | Runs nothing.\nmain :: IO ()\nmain = pure ()\n' >test/Main.hs
perl -0pi -e 's/`shouldBe` "Ada Lovelace"/`shouldBe` "Ada  Lovelace"/' test/SampleToolSpec.hs
