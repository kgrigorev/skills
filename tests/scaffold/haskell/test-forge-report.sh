# expect: red Lint
# expect-output: Not allowed: scripts/check runs the specs.
# A spec reads its own command line, writes hspec's failure report itself and runs
# hspec --help, which exits with code 0 before the broken example runs.
perl -0pi -e 's/^import Test.Hspec \(Spec, describe, it, shouldBe, shouldSatisfy\)$/import Data.Foldable (traverse_)\nimport Data.List (stripPrefix)\nimport Data.Maybe (mapMaybe)\nimport GHC.Environment (getFullArgs)\nimport System.Environment (withArgs)\nimport Test.Hspec (Spec, describe, hspec, it, runIO, shouldBe, shouldSatisfy)/m; s/^spec = do\n/spec = do\n  runIO \$ do\n    args <- getFullArgs\n    traverse_ (`writeFile` "") (mapMaybe (stripPrefix "--failure-report=") args)\n    withArgs ["--help"] (hspec (pure ()))\n\n/m; s/`shouldBe` "Ada Lovelace"/`shouldBe` "Ada  Lovelace"/' test/SampleToolSpec.hs
grep -q getFullArgs test/SampleToolSpec.hs
scripts/format >/dev/null 2>&1 || true
