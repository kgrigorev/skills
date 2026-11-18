# expect: red Lint
# Dynamic typing hides the types from the compiler.
perl -0pi -e 's/\(banner, tidyName\)/(banner, anyValue, tidyName)/; s/^(import Data.Text \(Text\))$/import Data.Dynamic (Dynamic, toDyn)\n$1/m' src/SampleTool.hs
cat >>src/SampleTool.hs <<'HS'

-- | Anything.
anyValue :: Int -> Dynamic
anyValue = toDyn
HS
