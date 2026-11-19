# expect: red No switched-off checks
# Two multi-line ignore comments, one per hint name, around a partial function.
perl -0pi -e 's/\(banner, tidyName\)/(banner, firstWord, tidyName)/' src/SampleTool.hs
cat >>src/SampleTool.hs <<'HS'

{-
HLINT ignore "Avoid partial function"
-}

{-
HLINT ignore "Avoid restricted function"
-}

-- | The first word.
firstWord :: Text -> Text
firstWord name = head (Text.words name)
HS
