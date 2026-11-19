# expect: red No switched-off checks
# expect-output: Control.Monad.ST.Unsafe (unsafeIOToST)
# A .cabal file that cabal never reads claims base's Control.Monad.ST.Unsafe as a project module.
mkdir -p docs
cat > docs/example.cabal <<'CABAL'
cabal-version: 3.12
name: sample-tool
version: 0
build-type: Simple

common common
  ghc-options:
    -Wall
    -Wcompat
    -Widentities
    -Wincomplete-record-updates
    -Wincomplete-uni-patterns
    -Wmissing-deriving-strategies
    -Wmissing-export-lists
    -Wmissing-home-modules
    -Wmissing-import-lists
    -Wpartial-fields
    -Wprepositive-qualified-module
    -Wredundant-constraints
    -Wunused-packages
    -haddock
    -Winvalid-haddock

library
  import: common
  exposed-modules: Control.Monad.ST.Unsafe
CABAL
perl -0pi -e 's/\(banner, tidyName\)/(banner, count, tidyName)/; s/^(import Data.Text \(Text\))$/import Control.Monad.ST (runST)\nimport Control.Monad.ST.Unsafe (unsafeIOToST)\n$1/m' src/SampleTool.hs
cat >>src/SampleTool.hs <<'HS'

-- | A count computed with IO inside pure code.
count :: Int
count = runST (unsafeIOToST (length <$> readFile "/etc/hosts"))
HS
scripts/format >/dev/null 2>&1 || true
