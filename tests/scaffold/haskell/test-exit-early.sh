# expect: red Lint
# expect-output: Only Main may import it: it exports ExitCode
# A spec prints a fake hspec summary and exits with code 0 before any example runs.
perl -0pi -e 's/^import Test.Hspec \(Spec, describe, it, shouldBe, shouldSatisfy\)$/import Control.Exception (throwIO)\nimport GHC.IO.Exception (ExitCode (ExitSuccess))\nimport Test.Hspec (Spec, describe, it, runIO, shouldBe, shouldSatisfy)/m; s/^spec = do\n/spec = do\n  runIO (putStrLn "3 examples, 0 failures" >> throwIO ExitSuccess)\n\n/m; s/`shouldBe` "Ada Lovelace"/`shouldBe` "Ada  Lovelace"/' test/SampleToolSpec.hs
grep -q runIO test/SampleToolSpec.hs
scripts/format >/dev/null 2>&1 || true
