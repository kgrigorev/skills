# expect: green
# A new library module with a record type, a total parser, and its own spec module.
perl -0pi -e 's/  exposed-modules: SampleTool\n/  exposed-modules:\n    SampleTool\n    SampleTool.Amount\n\n/; s/  other-modules: SampleToolSpec\n/  other-modules:\n    SampleTool.AmountSpec\n    SampleToolSpec\n\n/' sample-tool.cabal
mkdir -p src/SampleTool test/SampleTool
cat >src/SampleTool/Amount.hs <<'HS'
-- | Money amounts in whole cents, parsed from text such as @"12.50"@.
module SampleTool.Amount
  ( Amount (..),
    parseAmount,
    renderAmount,
  )
where

import Data.Text (Text)
import Data.Text qualified as Text
import Text.Read (readMaybe)

-- | An amount of money in cents.
newtype Amount = Amount {cents :: Int}
  deriving stock (Eq, Ord, Show)

-- | Parses @"12.50"@ or @"12"@. Returns 'Nothing' for anything else.
parseAmount :: Text -> Maybe Amount
parseAmount input = case Text.splitOn "." (Text.strip input) of
  [whole] -> toAmount whole "00"
  [whole, fraction] | Text.length fraction == 2 -> toAmount whole fraction
  _ -> Nothing
  where
    toAmount whole fraction = do
      w <- readMaybe (Text.unpack whole)
      f <- readMaybe (Text.unpack fraction)
      if w >= 0 && f >= 0 then Just (Amount (w * 100 + f)) else Nothing

-- | Renders an amount the way 'parseAmount' reads it.
renderAmount :: Amount -> Text
renderAmount (Amount c) =
  let (whole, fraction) = c `divMod` 100
      pad = if fraction < 10 then "0" else ""
   in Text.pack (show whole) <> "." <> pad <> Text.pack (show fraction)
HS
cat >test/SampleTool/AmountSpec.hs <<'HS'
-- | Tests for SampleTool.Amount.
module SampleTool.AmountSpec (spec) where

import SampleTool.Amount (Amount (Amount), parseAmount, renderAmount)
import Test.Hspec (Spec, describe, it, shouldBe)
import Test.Hspec.QuickCheck (prop)
import Test.QuickCheck (NonNegative (NonNegative), (===))

-- | The tests.
spec :: Spec
spec = describe "parseAmount" $ do
  it "reads cents" $
    parseAmount "12.50" `shouldBe` Just (Amount 1250)

  it "rejects three decimals" $
    parseAmount "1.234" `shouldBe` Nothing

  prop "reads what renderAmount writes" $ \(NonNegative c) ->
    parseAmount (renderAmount (Amount c)) === Just (Amount c)
HS
