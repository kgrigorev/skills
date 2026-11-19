# expect: red No switched-off checks
# expect-output: COMPLETE Red
# A COMPLETE pragma that names one of two constructors switches off -Wincomplete-patterns for
# the type, so a function that crashes on the other one builds.
perl -0pi -e 's/\(banner, tidyName\)/(Colour (..), banner, colourName, tidyName)/' src/SampleTool.hs
cat >>src/SampleTool.hs <<'HS'

-- | A colour.
data Colour = Red | Green
  deriving stock (Eq, Show)

{-# COMPLETE Red #-}

-- | Partial: crashes on Green.
colourName :: Colour -> Text
colourName Red = "red"
HS
scripts/format >/dev/null 2>&1 || true
