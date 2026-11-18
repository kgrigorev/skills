# expect: red Lint
# read is banned; readLn is the same partial parse in IO.
cat >app/Main.hs <<'HS'
-- | The sample-tool executable. Keep it thin: the work happens in the library.
module Main (main) where

import Data.Text.IO qualified as Text
import SampleTool (banner)

-- | Runs the program.
main :: IO ()
main = do
  Text.putStrLn banner
  n <- readLn
  print (n + 1 :: Int)
HS
