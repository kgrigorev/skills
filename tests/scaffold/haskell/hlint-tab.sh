# expect: red No switched-off checks
# HLint ignore pragmas with a tab after the hash.
perl -0pi -e 's/\(banner, tidyName\)/(banner, firstWord, tidyName)/' src/SampleTool.hs
printf '\n{-#\tHLINT ignore "Avoid restricted function" #-}\n{-#\tHLINT ignore "Avoid partial function" #-}\n\n-- | The first word.\nfirstWord :: Text -> Text\nfirstWord name = head (Text.words name)\n' >>src/SampleTool.hs
