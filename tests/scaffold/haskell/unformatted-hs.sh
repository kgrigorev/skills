# expect: red Format
# Code that Ormolu would lay out differently.
cat >>src/SampleTool.hs <<'HS'

-- | Two names.
twoNames   ::  Text -> Text->Text
twoNames a b = a <> " " <>   b
HS
perl -0pi -e 's/\(banner, tidyName\)/(banner, tidyName, twoNames)/' src/SampleTool.hs
