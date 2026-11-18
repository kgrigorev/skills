# expect: red Lint
# undefined and error instead of a Maybe or an Either.
perl -0pi -e 's/\(banner, tidyName\)/(banner, half, tidyName, todo)/' src/SampleTool.hs
cat >>src/SampleTool.hs <<'HS'

-- | Half of an even number.
half :: Int -> Int
half n = if even n then n `div` 2 else error "odd"

-- | Not written yet.
todo :: Int
todo = undefined
HS
