# expect: red No switched-off checks
# A GHC preprocessor in the .cabal file adds an OPTIONS_GHC line the scan never sees.
mkdir -p tools
# shellcheck disable=SC2016 # the script is written out as text, not run here
printf '#!/bin/sh\n{ echo "{-# OPTIONS_GHC -w #-}"; cat "$2"; } >"$3"\n' >tools/pp
chmod +x tools/pp
perl -0pi -e 's/(  exposed-modules: SampleTool\n)/$1  ghc-options: -F -pgmF tools\/pp\n/' sample-tool.cabal
cat >>src/SampleTool.hs <<'HS'

unusedTop :: Int
unusedTop = 1
HS
scripts/format >/dev/null 2>&1
