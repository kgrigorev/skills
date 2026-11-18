# expect: red Lint
# Data.Text's head is partial too.
perl -0pi -e 's/\(banner, tidyName\)/(banner, firstChar, tidyName)/' src/SampleTool.hs
cat >>src/SampleTool.hs <<'HS'

-- | The first character.
firstChar :: Text -> Char
firstChar = Text.head
HS
