# expect: red Build settings
# CPP switched on in the .cabal file; HLint reads the #else branch, GHC compiles the one with fromJust
# (head would trip GHC's own -Wx-partial).
perl -0pi -e 's/(  exposed-modules: SampleTool\n)/$1  default-extensions: CPP\n/' sample-tool.cabal
perl -0pi -e 's/\(banner, tidyName\)/(banner, firstName, tidyName)/; s/^(import Data.Text \(Text\))$/import Data.Maybe (fromJust)\n$1/m' src/SampleTool.hs
cat >>src/SampleTool.hs <<'HS'

-- | The first name.
firstName :: [Text] -> Text
#if defined(MIN_VERSION_base)
firstName names = fromJust (lookup "first" (zip ["first" :: Text] names))
#else
firstName _ = ""
#endif
HS
scripts/format >/dev/null 2>&1
