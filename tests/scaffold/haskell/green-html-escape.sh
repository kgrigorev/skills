# expect: green
# An HTML escaper whose local names say "unsafe" about characters, not about escape hatches.
perl -0pi -e 's/\(banner, tidyName\)/(banner, escapeHtml, tidyName)/' src/SampleTool.hs
cat >>src/SampleTool.hs <<'HS'

-- | The name, safe to put inside HTML.
escapeHtml :: Text -> Text
escapeHtml = Text.concatMap escapeChar
  where
    unsafeChars = "<>&\"'" :: String
    escapeChar c
      | c `elem` unsafeChars = "&#" <> Text.pack (show (fromEnum c)) <> ";"
      | otherwise = Text.singleton c
HS
perl -0pi -e 's/^import SampleTool \(banner, tidyName\)$/import SampleTool (banner, escapeHtml, tidyName)/m' test/SampleToolSpec.hs
cat >>test/SampleToolSpec.hs <<'HS'

  describe "escapeHtml"
    $ it "escapes markup characters"
    $ escapeHtml "<b>Ada & Bob</b>" `shouldBe` "&#60;b&#62;Ada &#38; Bob&#60;/b&#62;"
HS
scripts/format >/dev/null 2>&1
