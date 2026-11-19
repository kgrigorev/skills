# expect: red Lint
# maximum and the ! operator fail on empty or short inputs.
perl -0pi -e 's/\(banner, tidyName\)/(banner, largest, tidyName)/' src/SampleTool.hs
cat >>src/SampleTool.hs <<'HS'

-- | The largest value.
largest :: [Int] -> Int
largest = maximum
HS
