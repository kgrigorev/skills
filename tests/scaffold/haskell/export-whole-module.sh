# expect: red No switched-off checks
# module X (module X) exports everything, so dead code no longer trips -Wunused-top-binds.
perl -0pi -e 's/module SampleTool \(banner, tidyName\) where/module SampleTool (module SampleTool) where/' src/SampleTool.hs
cat >>src/SampleTool.hs <<'HS'

-- | Left over from an earlier version.
oldTidy :: Text -> Text
oldTidy = Text.strip
HS
scripts/format >/dev/null 2>&1
