# expect: green
# A tool that counts Haskell comments has "{-" and "--" string literals, and a help string that
# names unsafePerformIO as text.
perl -0pi -e 's/\(banner, tidyName\)/(banner, commentCounts, lintHelp, tidyName)/' src/SampleTool.hs
cat >>src/SampleTool.hs <<'HS'

-- | How many block and line comments a Haskell source has.
commentCounts :: Text -> (Int, Int)
commentCounts source = (Text.count "{-" source, Text.count "--" source)

-- | The help line for the lint command.
lintHelp :: Text
lintHelp = "Reports calls to unsafePerformIO and other escape hatches."
HS
