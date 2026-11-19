# expect: red No switched-off checks
# expect-output: import GHC.IO (unsafeUnmask)
# A file that no component builds claims the module name GHC.IO, so the scan would treat base's
# GHC.IO as one of the project's own modules. Only the .cabal module lists count.
mkdir -p docs
printf -- '-- | An example for the docs.\nmodule GHC.IO () where\n' >docs/Example.hs
perl -0pi -e 's/\(banner, tidyName\)/(banner, masked, tidyName)/; s/^(import Data.Text qualified as Text)$/$1\nimport GHC.IO (unsafeUnmask)/m' src/SampleTool.hs
cat >>src/SampleTool.hs <<'HS'

-- | Runs an action with async exceptions unmasked.
masked :: IO () -> IO ()
masked = unsafeUnmask
HS
scripts/format >/dev/null 2>&1 || true
