# expect: red Format
# Ormolu's switch-off comment, written as a line comment, around unformatted code.
cat >>src/SampleTool.hs <<'HS'

-- ORMOLU_DISABLE
-- | Two names.
twoNames   ::  Text -> Text->Text
twoNames a b = a <> " " <>   b
-- ORMOLU_ENABLE
HS
perl -0pi -e 's/\(banner, tidyName\)/(banner, tidyName, twoNames)/' src/SampleTool.hs
