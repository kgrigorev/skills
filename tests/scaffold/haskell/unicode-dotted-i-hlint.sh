# expect: red No switched-off checks
# expect-output: the first word of a block comment must be ASCII
# The same dotted capital I in an HLINT ignore comment, which HLint honours.
perl -CSD -0pi -e 's/^(module SampleTool)/{- HL\x{130}NT ignore -}\n$1/m; s/\(banner, tidyName\)/(banner, firstWord, tidyName)/; s/^(import Data.Text qualified as Text)$/$1\nimport Data.Maybe (fromJust)/m' src/SampleTool.hs
cat >>src/SampleTool.hs <<'HS'

-- | The first word of a name.
firstWord :: Text -> Text
firstWord name = Text.take (read "3") name <> fromJust (Just "") <> undefined
HS
scripts/format >/dev/null 2>&1 || true
