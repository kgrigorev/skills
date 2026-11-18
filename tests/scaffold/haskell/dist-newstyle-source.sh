# expect: red Build settings
# A source folder under dist-newstyle/: git ignores it, and the ignored-file check skips that
# folder, so format, lint and the scan never read the module.
mkdir -p dist-newstyle/hidden-src
cat >dist-newstyle/hidden-src/Hidden.hs <<'HS'
{-# OPTIONS_GHC -w #-}
module Hidden (first) where
import Data.Maybe (fromJust)
first :: [Int] -> Int
first xs = head xs + fromJust (Just 1)
HS
perl -0pi -e 's/  hs-source-dirs: src\n  exposed-modules: SampleTool\n/  hs-source-dirs:\n    dist-newstyle\/hidden-src\n    src\n\n  exposed-modules:\n    Hidden\n    SampleTool\n\n/' sample-tool.cabal
grep -q hidden-src sample-tool.cabal
scripts/format >/dev/null 2>&1
