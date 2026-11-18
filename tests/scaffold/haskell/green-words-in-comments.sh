# expect: green
# Comments, Haddock and strings that name the banned things without using them.
perl -0pi -e 's/\(banner, tidyName\)/(Safety (..), banner, classify, isUnsafePath, tidyName, warningHint)/' src/SampleTool.hs
cat >>src/SampleTool.hs <<'HS'

-- | Whether a path may be written to. Not unsafePerformIO, not Data.Text.Unsafe: plain data.
-- HLint and -Wno-unused-imports have nothing to do with it.
data Safety = Safe | Unsafe
  deriving stock (Eq, Show)

-- | Paths outside the project are unsafe.
isUnsafePath :: Text -> Bool
isUnsafePath path = ".." `Text.isInfixOf` path

-- | Classifies a path (see 'isUnsafePath').
classify :: Text -> Safety
classify path = if isUnsafePath path then Unsafe else Safe

-- | The hint the tool prints. It names flags and pragmas only as text.
warningHint :: Text
warningHint = "Do not switch warnings off with -Wno-* or HLint: ignore. Fix them."
HS
