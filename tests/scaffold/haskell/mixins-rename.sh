# expect: red Build settings
# expect-output: mixins: a rename hides which module of another package is used
# mixins renames text's Data.Text.Unsafe to SampleTool.Fast, so the rule for modules with an
# Unsafe part in their name never sees it. iter reads a character without a bounds check.
perl -0pi -e 's/^(library\n  import: common\n  hs-source-dirs: src\n  exposed-modules: SampleTool\n  build-depends: text \^>=\S+)\n/$1\n  mixins:\n    text,\n    text (Data.Text.Unsafe as SampleTool.Fast),\n/m' sample-tool.cabal
grep -q 'as SampleTool.Fast' sample-tool.cabal
perl -0pi -e 's/\(banner, tidyName\)/(banner, firstCode, tidyName)/; s/^(import Data.Text qualified as Text)$/$1\nimport SampleTool.Fast (Iter (Iter), iter)/m' src/SampleTool.hs
cat >>src/SampleTool.hs <<'HS'

-- | The first character of a name, read without a bounds check.
firstCode :: Text -> Char
firstCode name = case iter name 0 of Iter c _ -> c
HS
scripts/format >/dev/null 2>&1 || true
