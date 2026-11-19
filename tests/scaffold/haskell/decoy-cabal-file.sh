# expect: red Build settings
# expect-output: cabal does not read this file
# A .cabal file outside cabal.project's packages, which no build reads.
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
scripts/format >/dev/null 2>&1 || true
