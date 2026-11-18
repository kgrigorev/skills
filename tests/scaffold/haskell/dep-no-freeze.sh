# expect: red Dependency versions match cabal.project.freeze
# A new dependency without running scripts/freeze.
perl -0pi -e 's/  exposed-modules: SampleTool\n  build-depends: text \^>=(\S+)\n/  exposed-modules: SampleTool\n  build-depends:\n    split ^>=0.2,\n    text ^>=$1,\n/' sample-tool.cabal
perl -0pi -e 's/\(banner, tidyName\)/(banner, fields, tidyName)/; s/^(import Data.Text \(Text\))$/import Data.List.Split (splitOn)\n$1/m' src/SampleTool.hs
cat >>src/SampleTool.hs <<'HS'

-- | The comma-separated fields.
fields :: String -> [String]
fields = splitOn ","
HS
