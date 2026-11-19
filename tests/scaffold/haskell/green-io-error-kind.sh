# expect: green
# A broken-pipe check for a CLI through System.IO.Error, the allowed way to read an IO error's kind.
perl -0pi -e 's/\(banner, tidyName\)/(banner, isBrokenPipe, tidyName)/; s/^(import Data.Text \(Text\))$/$1\nimport System.IO.Error (isResourceVanishedError)/m' src/SampleTool.hs
cat >>src/SampleTool.hs <<'HS'

-- | Whether writing failed because the reader closed the pipe, as with @sample-tool | head@.
isBrokenPipe :: IOError -> Bool
isBrokenPipe = isResourceVanishedError
HS
scripts/format >/dev/null 2>&1 || true
