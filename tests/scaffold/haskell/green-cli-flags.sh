# expect: green
# A command line that accepts -w and -W as options, written as strings.
perl -0pi -e 's/\(banner, tidyName\)/(Width (..), banner, parseWidth, tidyName)/; s/^(import Data.Text qualified as Text)$/$1\nimport Text.Read (readMaybe)/m' src/SampleTool.hs
cat >>src/SampleTool.hs <<'HS'

-- | The output width in columns.
newtype Width = Width Int
  deriving stock (Eq, Show)

-- | Reads @-w 80@, @-W 80@ or @--width 80@ from the arguments.
parseWidth :: [String] -> Maybe Width
parseWidth args = case args of
  "-w" : n : _ -> Width <$> readMaybe n
  "-W" : n : _ -> Width <$> readMaybe n
  "--width" : n : _ -> Width <$> readMaybe n
  _ : rest -> parseWidth rest
  [] -> Nothing
HS
