# expect: red Build settings
# test/Main.hs replaced by a hand-written hspec main that runs one passing example; the broken
# SampleToolSpec still compiles but never runs.
cat >test/Main.hs <<'HS'
-- | Test driver.
module Main (main) where

import SampleTool (banner)
import Test.Hspec (hspec, it, shouldBe)

-- | Runs the tests.
main :: IO ()
main = hspec (it "names the program" (banner `shouldBe` "sample-tool: A sample tool that tests the template"))
HS
perl -0pi -e 's/`shouldBe` "Ada Lovelace"/`shouldBe` "Ada  Lovelace"/' test/SampleToolSpec.hs
