# expect: red Lint
# A multi-line HLint ignore comment for one hint name; the partial-function hint still fires.
perl -0pi -e 's/\(banner, tidyName\)/(banner, firstWord, tidyName)/' src/SampleTool.hs
cat >>src/SampleTool.hs <<'HS'

{-
HLINT ignore "Avoid restricted function"
-}

-- | The first word.
firstWord :: Text -> Text
firstWord name = head (Text.words name)
HS
