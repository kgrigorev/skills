# expect: red Lint
# The spec switches hspec to dry-run from inside: every example "passes" without running.
perl -0pi -e 's/    hspec \^>=(\S+),\n/    hspec ^>=$1,\n    hspec-core ^>=$1,\n/' sample-tool.cabal
perl -0pi -e 's/^(import Test.Hspec \(.*\))$/$1\nimport Test.Hspec.Core.Spec (modifyConfig)\nimport Test.Hspec.Runner (Config (configDryRun))/m; s/^spec = do\n/spec = do\n  modifyConfig (\\config -> config {configDryRun = True})\n\n/m; s/`shouldBe` "Ada Lovelace"/`shouldBe` "Ada  Lovelace"/' test/SampleToolSpec.hs
scripts/format >/dev/null 2>&1
grep -q configDryRun test/SampleToolSpec.hs
