# expect: green
# An I/O shell over a tested pure core: the library parses "name,age" lines into records or a
# typed error, Main reads stdin, prints the report or the errors, and exits with a code.
perl -0pi -e 's/\(banner, tidyName\)/(\n  Person (..),\n  RowError (..),\n  banner,\n  parsePeople,\n  parseRow,\n  report,\n  tidyName,\n)/; s/^(import Data.Text qualified as Text)$/$1\nimport Text.Read (readMaybe)/m; s/^(import Data.Text \(Text\))$/import Data.List (sortOn)\nimport Data.Ord (Down (Down))\n$1/m' src/SampleTool.hs
cat >>src/SampleTool.hs <<'HS'

-- | One person from the input.
data Person = Person
  { personName :: !Text,
    personAge :: !Int
  }
  deriving stock (Eq, Show)

-- | Why a line of the input is not a person.
data RowError
  = MissingComma Int
  | BadAge Int Text
  | BlankName Int
  deriving stock (Eq, Show)

-- | Parses one numbered @name,age@ line.
parseRow :: Int -> Text -> Either RowError Person
parseRow n line = case Text.splitOn "," line of
  [rawName, rawAge]
    | Text.null name -> Left (BlankName n)
    | otherwise -> case readMaybe (Text.unpack (Text.strip rawAge)) of
        Just age | age >= 0 -> Right (Person name age)
        _ -> Left (BadAge n rawAge)
    where
      name = tidyName rawName
  _ -> Left (MissingComma n)

-- | Parses every non-blank line, numbering lines from 1.
parsePeople :: Text -> Either RowError [Person]
parsePeople input =
  traverse (uncurry parseRow) [(n, line) | (n, line) <- zip [1 ..] (Text.lines input), not (Text.null (Text.strip line))]

-- | One line per person, oldest first.
report :: [Person] -> Text
report people = Text.unlines [personName p <> " (" <> Text.pack (show (personAge p)) <> ")" | p <- sortOn (Down . personAge) people]
HS
cat >app/Main.hs <<'HS'
-- | The sample-tool executable. Keep it thin: the work happens in the library.
module Main (main) where

import Data.Text.IO qualified as Text
import SampleTool (parsePeople, report)
import System.Exit (ExitCode (ExitFailure), exitWith)
import System.IO (hPutStrLn, stderr)

-- | Reads people from standard input and prints them oldest first.
main :: IO ()
main = do
  input <- Text.getContents
  case parsePeople input of
    Right people -> Text.putStr (report people)
    Left err -> do
      hPutStrLn stderr ("sample-tool: " <> show err)
      exitWith (ExitFailure 2)
HS
perl -0pi -e 's/^import SampleTool \(banner, tidyName\)$/import SampleTool (Person (Person), RowError (BadAge, BlankName, MissingComma), banner, parsePeople, parseRow, report, tidyName)/m; s/^import Test.QuickCheck \(\(===\)\)$/import Test.QuickCheck (NonNegative (NonNegative), (===))/m' test/SampleToolSpec.hs
cat >>test/SampleToolSpec.hs <<'HS'

  describe "parseRow" $ do
    it "reads a name and an age" $
      parseRow 1 " Ada  Lovelace , 36" `shouldBe` Right (Person "Ada Lovelace" 36)

    it "reports each kind of bad line" $ do
      parseRow 1 "Ada" `shouldBe` Left (MissingComma 1)
      parseRow 2 "Ada,old" `shouldBe` Left (BadAge 2 "old")
      parseRow 3 " ,4" `shouldBe` Left (BlankName 3)

    prop "reads back any age it is given" $ \(NonNegative age) ->
      parseRow 1 ("Ada," <> Text.pack (show age)) === Right (Person "Ada" age)

  describe "parsePeople and report" $ do
    it "skips blank lines and sorts oldest first" $
      fmap report (parsePeople "Bob,20\n\nAda,36\n") `shouldBe` Right "Ada (36)\nBob (20)\n"

    it "stops at the first bad line" $
      parsePeople "Bob,20\nAda\n" `shouldBe` Left (MissingComma 2)
HS
scripts/format >/dev/null 2>&1
