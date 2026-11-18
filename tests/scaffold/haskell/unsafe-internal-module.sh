# expect: red No switched-off checks
# unsafePerformIO under a name without "unsafe" in it.
perl -0pi -e 's/  exposed-modules: SampleTool\n  build-depends: text \^>=(\S+)\n/  exposed-modules: SampleTool\n  build-depends:\n    bytestring ^>=0.12,\n    text ^>=$1,\n/' sample-tool.cabal
perl -0pi -e 's/\(banner, tidyName\)/(banner, sneaky, tidyName)/; s/^(import Data.Text \(Text\))$/import Data.ByteString.Internal (accursedUnutterablePerformIO)\n$1/m' src/SampleTool.hs
cat >>src/SampleTool.hs <<'HS'

-- | IO in pure code.
sneaky :: Int -> Int
sneaky x = accursedUnutterablePerformIO (pure x)
HS
