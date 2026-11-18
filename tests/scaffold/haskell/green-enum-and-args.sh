# expect: green
# A bounded enum listed with minBound..maxBound, a "--" argument separator, and Either parsing.
perl -0pi -e 's/\(banner, tidyName\)/(Mode (..), banner, modeNames, parseArgs, parseMode, tidyName)/; s/^(import Data.Text qualified as Text)$/$1\nimport Text.Read (readMaybe)/m' src/SampleTool.hs
cat >>src/SampleTool.hs <<'HS'

-- | How names are printed.
data Mode = Plain | Upper | Lower
  deriving stock (Eq, Ord, Show, Read, Enum, Bounded)

-- | Every mode, by name, for the help text.
modeNames :: [Text]
modeNames = [Text.pack (show mode) | mode <- [minBound .. maxBound :: Mode]]

-- | Reads a mode name such as @"Upper"@.
parseMode :: String -> Either Text Mode
parseMode s = maybe (Left ("unknown mode: " <> Text.pack s)) Right (readMaybe s)

-- | Splits options from names at @--@, so @["-m", "Upper", "--", "-x"]@ has the name @"-x"@.
parseArgs :: [String] -> Either Text (Mode, [String])
parseArgs args = case break (== "--") args of
  (["-m", m], _ : names) -> fmap (,names) (parseMode m)
  ([], _ : names) -> Right (Plain, names)
  (names, []) -> Right (Plain, names)
  _ -> Left "Usage: sample-tool [-m MODE] -- NAME..."
HS
cat >>test/SampleToolSpec.hs <<'HS'

  describe "parseArgs" $ do
    it "keeps names after --" $
      parseArgs ["-m", "Upper", "--", "-x"] `shouldBe` Right (Upper, ["-x"])

    it "lists every mode" $
      modeNames `shouldBe` ["Plain", "Upper", "Lower"]
HS
perl -0pi -e 's/import SampleTool \(banner, tidyName\)/import SampleTool (Mode (Upper), banner, modeNames, parseArgs, tidyName)/' test/SampleToolSpec.hs
# An agent formats before it checks.
scripts/format >/dev/null 2>&1
