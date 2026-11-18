# expect: red No switched-off checks
# An unsafe function that base re-exports from a module without Unsafe in its name.
perl -0pi -e 's/\(banner, tidyName\)/(banner, masked, tidyName)/; s/^(import Data.Text qualified as Text)$/$1\nimport GHC.IO (unsafeUnmask)/m' src/SampleTool.hs
cat >>src/SampleTool.hs <<'HS'

-- | Runs an action with async exceptions unmasked.
masked :: IO () -> IO ()
masked = unsafeUnmask
HS
