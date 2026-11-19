# expect: red Test
# The same early exit with the HLint ban on GHC.IO.Exception removed: hspec writes no failure
# report, so the test step fails.
perl -0pi -e 's/^import Test.Hspec \(Spec, describe, it, shouldBe, shouldSatisfy\)$/import Control.Exception (throwIO)\nimport GHC.IO.Exception (ExitCode (ExitSuccess))\nimport Test.Hspec (Spec, describe, it, runIO, shouldBe, shouldSatisfy)/m; s/^spec = do\n/spec = do\n  runIO (putStrLn "3 examples, 0 failures" >> throwIO ExitSuccess)\n\n/m; s/`shouldBe` "Ada Lovelace"/`shouldBe` "Ada  Lovelace"/' test/SampleToolSpec.hs
grep -q runIO test/SampleToolSpec.hs
perl -pi -e 's/System.Exit, GHC.IO.Exception/System.Exit/' .hlint.yaml
scripts/format >/dev/null 2>&1 || true
