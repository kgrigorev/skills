# expect: red No switched-off checks
# expect-output: import Data.ByteString.Internal (c2w)
# An import from another package's Internal module, whose exports such as
# accursedUnutterablePerformIO are unsafe. The rule rejects the module, whatever name is used.
perl -0pi -e 's/  exposed-modules: SampleTool\n  build-depends: text \^>=(\S+)\n/  exposed-modules: SampleTool\n  build-depends:\n    bytestring ^>=0.12,\n    text ^>=$1,\n/' sample-tool.cabal
perl -0pi -e 's/\(banner, tidyName\)/(banner, byteOf, tidyName)/; s/^(import Data.Text \(Text\))$/import Data.ByteString.Internal (c2w)\nimport Data.Word (Word8)\n$1/m' src/SampleTool.hs
cat >>src/SampleTool.hs <<'HS'

-- | The byte of an ASCII character.
byteOf :: Char -> Word8
byteOf = c2w
HS
scripts/format >/dev/null 2>&1 || true
