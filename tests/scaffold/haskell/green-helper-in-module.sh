# expect: green
# A new total helper in the existing module, exported and tested.
perl -0pi -e 's/\(banner, tidyName\)/(banner, initials, tidyName)/' src/SampleTool.hs
cat >>src/SampleTool.hs <<'HS'

-- | The first letter of each word, so @"ada lovelace"@ becomes @"AL"@.
initials :: Text -> Text
initials name = Text.toUpper (Text.concat (map (Text.take 1) (Text.words name)))
HS
perl -0pi -e 's/import SampleTool \(banner, tidyName\)/import SampleTool (banner, initials, tidyName)/' test/SampleToolSpec.hs
cat >>test/SampleToolSpec.hs <<'HS'

  describe "initials" $ do
    it "takes the first letter of each word" $
      initials "ada lovelace" `shouldBe` "AL"

    it "is empty for an empty name" $
      initials "" `shouldBe` ""
HS
