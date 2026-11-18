# expect: red No switched-off checks
# An Unsafe module imported qualified, its function used through the alias.
perl -0pi -e 's/\(banner, tidyName\)/(banner, firstChar, tidyName)/; s/^(import Data.Text qualified as Text)$/$1\nimport Data.Text.Unsafe qualified as U/m' src/SampleTool.hs
cat >>src/SampleTool.hs <<'HS'

-- | The first character, unchecked.
firstChar :: Text -> Int
firstChar = U.lengthWord8
HS
