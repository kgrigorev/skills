# expect: green
# The executable handles a missing file at the shell: try @IOException, a message, exit 1.
cat >app/Main.hs <<'HS'
-- | The sample-tool executable. Keep it thin: the work happens in the library.
module Main (main) where

import Control.Exception (IOException, try)
import Data.Foldable (traverse_)
import Data.Text qualified as Text
import Data.Text.IO qualified as Text
import SampleTool (tidyName)
import System.Environment (getArgs)
import System.Exit (exitFailure)
import System.IO (hPutStrLn, stderr)

-- | Prints each file's names tidied, one per line.
main :: IO ()
main = getArgs >>= traverse_ printFile

-- | Prints one file, or reports why it cannot be read.
printFile :: FilePath -> IO ()
printFile path = do
  result <- try @IOException (Text.readFile path)
  case result of
    Left err -> do
      hPutStrLn stderr ("sample-tool: cannot read " <> path <> ": " <> show err)
      exitFailure
    Right contents -> traverse_ (Text.putStrLn . tidyName) (Text.lines contents)
HS
scripts/format >/dev/null 2>&1
