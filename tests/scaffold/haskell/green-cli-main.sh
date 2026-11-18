# expect: green
# A real executable: arguments, a file read, errors to stderr and a failing exit code.
cat >app/Main.hs <<'HS'
-- | The sample-tool executable. Keep it thin: the work happens in the library.
module Main (main) where

import Data.Foldable (for_)
import Data.Text qualified as Text
import Data.Text.IO qualified as Text
import SampleTool (banner, tidyName)
import System.Environment (getArgs)
import System.Exit (exitFailure)
import System.IO (hPutStrLn, stderr)

-- | Reads the names in a file, one per line, and prints them tidied.
main :: IO ()
main = do
  args <- getArgs
  case args of
    [path] -> do
      Text.putStrLn banner
      contents <- Text.readFile path
      for_ (Text.lines contents) (Text.putStrLn . tidyName)
    _ -> do
      hPutStrLn stderr "Usage: sample-tool <file>"
      exitFailure
HS
# An agent formats before it checks.
scripts/format >/dev/null 2>&1
