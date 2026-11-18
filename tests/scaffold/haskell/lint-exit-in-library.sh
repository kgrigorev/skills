# expect: red Lint
# The library exits the process on bad input instead of returning an Either.
perl -0pi -e 's/\(banner, tidyName\)/(banner, requireName, tidyName)/; s/^(import Data.Text qualified as Text)$/$1\nimport System.Exit (exitFailure)/m' src/SampleTool.hs
cat >>src/SampleTool.hs <<'HS'

-- | The tidied name, or the program stops.
requireName :: Text -> IO Text
requireName name
  | Text.null (tidyName name) = exitFailure
  | otherwise = pure (tidyName name)
HS
scripts/format >/dev/null 2>&1
