# expect: green
# A second executable that imports the common stanza and uses the library.
printf '\nexecutable sample-tool-report\n  import: common\n  hs-source-dirs: report\n  main-is: Main.hs\n  build-depends:\n    sample-tool,\n    text,\n' >>sample-tool.cabal
mkdir report
cat >report/Main.hs <<'HS'
-- | Prints each command-line argument as a tidy name.
module Main (main) where

import Data.Foldable (for_)
import Data.Text qualified as Text
import Data.Text.IO qualified as Text
import SampleTool (tidyName)
import System.Environment (getArgs)

-- | Runs the report.
main :: IO ()
main = do
  args <- getArgs
  for_ args $ \arg -> Text.putStrLn (tidyName (Text.pack arg))
HS
