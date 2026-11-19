# expect: red Lint
# A Liquid-Haskell-style {-@ comment that HLint does not read as an ignore.
perl -0pi -e 's/\(banner, tidyName\)/(banner, firstWord, tidyName)/' src/SampleTool.hs
cat >>src/SampleTool.hs <<'HS'

{-@ HLINT ignore "Avoid restricted function" @-}

-- | The first word.
firstWord :: Text -> Text
firstWord name = head (Text.words name)
HS
