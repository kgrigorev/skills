# expect: red Build
# An unused top-level binding: a warning, so an error.
cat >>src/SampleTool.hs <<'HS'

unusedTop :: Int
unusedTop = 1
HS
