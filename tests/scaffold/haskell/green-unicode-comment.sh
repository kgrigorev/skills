# expect: green
# Non-ASCII text after "-- " and inside a block comment that starts with an ASCII word.
perl -CSD -0pi -e 's/^(tidyName ::)/-- \x{2192} Grüße, «quoted»\n{- Note: λ-calculus. -}\n$1/m' src/SampleTool.hs
scripts/format >/dev/null 2>&1 || true
