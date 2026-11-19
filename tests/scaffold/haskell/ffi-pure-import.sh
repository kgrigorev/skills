# expect: red No switched-off checks
# expect-output: foreign import: calls C code
# A foreign import with a pure type: an impure C call that the types call pure.
perl -0pi -e 's/\(banner, tidyName\)/(banner, randomNumber, tidyName)/' src/SampleTool.hs
cat >>src/SampleTool.hs <<'HS'

-- | A number from C.
foreign import ccall "rand" randomNumber :: Int
HS
scripts/format >/dev/null 2>&1 || true
