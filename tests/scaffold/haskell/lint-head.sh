# expect: red Lint
# A partial function that GHC only warns about and HLint bans.
perl -0pi -e 's/\(banner, tidyName\)/(banner, firstName, tidyName)/' src/SampleTool.hs
cat >>src/SampleTool.hs <<'HS'

-- | The first name.
firstName :: [Text] -> Text
firstName names = head names
HS
