# expect: green
# The total alternative the lint message recommends: a NonEmpty and its head.
perl -0pi -e 's/\(banner, tidyName\)/(banner, firstName, tidyName)/; s/^(import Data.Text \(Text\))$/import Data.List.NonEmpty (NonEmpty)\nimport Data.List.NonEmpty qualified as NonEmpty\n$1/m' src/SampleTool.hs
cat >>src/SampleTool.hs <<'HS'

-- | The first of at least one name.
firstName :: NonEmpty Text -> Text
firstName = NonEmpty.head
HS
