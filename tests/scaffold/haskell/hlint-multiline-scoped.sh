# expect: red No switched-off checks
# A multi-line ignore comment scoped to one function.
perl -0pi -e 's/\(banner, tidyName\)/(banner, firstWord, tidyName)/' src/SampleTool.hs
cat >>src/SampleTool.hs <<'HS'

{-
HLINT ignore firstWord
-}

-- | The first word.
firstWord :: Text -> Text
firstWord name = head (Text.words name)
HS
