# expect: red Lint
# The lazy foldl builds up thunks.
perl -0pi -e 's/\(banner, tidyName\)/(banner, total, tidyName)/' src/SampleTool.hs
cat >>src/SampleTool.hs <<'HS'

-- | The sum.
total :: [Int] -> Int
total = foldl (+) 0
HS
