# expect: red Build (warnings
# A case that misses a constructor.
perl -0pi -e 's/\(banner, tidyName\)/(banner, describe, tidyName)/' src/SampleTool.hs
cat >>src/SampleTool.hs <<'HS'

-- | Describes a count.
describe :: Maybe Int -> Text
describe count = case count of
  Just _ -> "some"
HS
