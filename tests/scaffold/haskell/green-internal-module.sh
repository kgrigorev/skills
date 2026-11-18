# expect: green
# The project's own Internal module, with a helper whose name starts with "unsafe", used
# through a qualifier. Only Unsafe and Internal modules from other packages are banned.
perl -0pi -e 's/  exposed-modules: SampleTool\n/  exposed-modules: SampleTool\n  other-modules: SampleTool.Internal\n/' sample-tool.cabal
mkdir -p src/SampleTool
cat >src/SampleTool/Internal.hs <<'HS'
-- | Helpers that the SampleTool module builds on.
module SampleTool.Internal (unsafeSpaces) where

import Data.Text (Text)
import Data.Text qualified as Text

-- | The spaces in a name that tidyName removes: "unsafe" for display, not for the program.
unsafeSpaces :: Text -> Int
unsafeSpaces name = Text.length name - Text.length (Text.unwords (Text.words name))
HS
perl -0pi -e 's/\(banner, tidyName\)/(banner, extraSpaces, tidyName)/; s/^(import Data.Text qualified as Text)$/$1\nimport SampleTool.Internal qualified as Internal/m' src/SampleTool.hs
cat >>src/SampleTool.hs <<'HS'

-- | How many spaces tidyName drops.
extraSpaces :: Text -> Int
extraSpaces = Internal.unsafeSpaces
HS
scripts/format >/dev/null 2>&1
