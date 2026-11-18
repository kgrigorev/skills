# expect: green
# A module with digits and an underscore in its name, and non-Haskell files with spaces and
# unusual characters, which the gates must not try to read as Haskell.
perl -0pi -e 's/  exposed-modules: SampleTool\n/  exposed-modules:\n    SampleTool\n    SampleTool.V2_Format\n\n/' sample-tool.cabal
mkdir -p src/SampleTool docs 'test/fixtures/odd names'
cat >src/SampleTool/V2_Format.hs <<'HS'
-- | Version 2 of the output format.
module SampleTool.V2_Format (formatV2) where

import Data.Text (Text)

-- | Formats a name for version 2.
formatV2 :: Text -> Text
formatV2 name = "v2:" <> name
HS
printf '# Design notes\n\nWe never use {-# OPTIONS_GHC -Wno-x #-} or -w.\n' >'docs/design notes (draft).md'
printf 'Ada   Lovelace\n' >"test/fixtures/odd names/input #1 it's.txt"
