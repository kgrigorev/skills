# expect: red Build (warnings
# deriving without a strategy (-Wmissing-deriving-strategies).
perl -0pi -e 's/\(banner, tidyName\)/(Account (..), banner, tidyName)/' src/SampleTool.hs
cat >>src/SampleTool.hs <<'HS'

-- | An account.
newtype Account = Account Text
  deriving (Eq, Show)
HS
