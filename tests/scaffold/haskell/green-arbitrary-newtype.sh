# expect: green
# A property with its own generator: a newtype in the test module with an Arbitrary instance,
# deriving newtype, cover/checkCoverage, and a strict record in the library.
perl -0pi -e 's/\(banner, tidyName\)/(Greeting (..), banner, greet, tidyName)/' src/SampleTool.hs
cat >>src/SampleTool.hs <<'HS'

-- | A greeting for one person.
data Greeting = Greeting
  { greetingName :: !Text,
    greetingText :: !Text
  }
  deriving stock (Eq, Show)

-- | Greets a name, tidied first.
greet :: Text -> Greeting
greet name = Greeting tidy ("Hello, " <> tidy <> "!")
  where
    tidy = tidyName name
HS
perl -0pi -e 's/^import SampleTool \(banner, tidyName\)$/import SampleTool (Greeting (greetingName, greetingText), banner, greet, tidyName)/m; s/^import Test.QuickCheck \(\(===\)\)$/import Test.QuickCheck (Arbitrary (arbitrary, shrink), checkCoverage, cover, elements, listOf, (===))/m' test/SampleToolSpec.hs
cat >>test/SampleToolSpec.hs <<'HS'

  describe "greet" $ do
    prop "greets the tidied name" $ \(Spaced name) ->
      checkCoverage
        $ cover 10 (Text.any (== ' ') name) "has spaces"
        $ greetingText (greet name)
        === "Hello, "
        <> greetingName (greet name)
        <> "!"

    it "tidies before greeting" $
      greetingText (greet "  Ada ") `shouldBe` "Hello, Ada!"

-- | Names made of letters and spaces.
newtype Spaced = Spaced Text.Text
  deriving newtype (Show)

instance Arbitrary Spaced where
  arbitrary = Spaced . Text.pack <$> listOf (elements "ab  ")
  shrink (Spaced t) = [Spaced (Text.pack s) | s <- shrink (Text.unpack t)]
HS
scripts/format >/dev/null 2>&1
