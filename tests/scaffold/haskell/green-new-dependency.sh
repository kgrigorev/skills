# expect: green
# A new dependency that the freeze file already pins (containers comes with QuickCheck), used
# through Data.Map.Strict.
perl -0pi -e 's/  exposed-modules: SampleTool\n  build-depends: text \^>=(\S+)\n/  exposed-modules: SampleTool\n  build-depends:\n    containers ^>=0.8,\n    text ^>=$1,\n/' sample-tool.cabal
perl -0pi -e 's/\(banner, tidyName\)/(banner, countWords, tidyName)/; s/^(import Data.Text \(Text\))$/import Data.Map.Strict (Map)\nimport Data.Map.Strict qualified as Map\n$1/m' src/SampleTool.hs
cat >>src/SampleTool.hs <<'HS'

-- | How often each word occurs.
countWords :: Text -> Map Text Int
countWords text = Map.fromListWith (+) [(word, 1) | word <- Text.words text]
HS
