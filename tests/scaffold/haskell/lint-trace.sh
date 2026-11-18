# expect: red Lint
# Debug output left in the library.
perl -0pi -e 's/\(banner, tidyName\)/(banner, loud, tidyName)/; s/^(import Data.Text qualified as Text)$/$1\nimport Debug.Trace (trace)/m' src/SampleTool.hs
cat >>src/SampleTool.hs <<'HS'

-- | A value, with debug output.
loud :: Int -> Int
loud x = trace "loud" x
HS
