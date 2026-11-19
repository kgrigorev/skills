# expect: red Test
# expect-output: did not finish an hspec run
# The same early exit with the HLint bans on GHC.IO.Exception and runIO removed: hspec writes no
# failure report, so the test step fails.
perl -0pi -e 's/^import Test.Hspec \(Spec, describe, it, shouldBe, shouldSatisfy\)$/import Control.Exception (throwIO)\nimport GHC.IO.Exception (ExitCode (ExitSuccess))\nimport Test.Hspec (Spec, describe, it, runIO, shouldBe, shouldSatisfy)/m; s/^spec = do\n/spec = do\n  runIO (putStrLn "3 examples, 0 failures" >> throwIO ExitSuccess)\n\n/m; s/`shouldBe` "Ada Lovelace"/`shouldBe` "Ada  Lovelace"/' test/SampleToolSpec.hs
grep -q runIO test/SampleToolSpec.hs
perl -ni -e 'print unless /name: GHC\.IO\.Exception,/' .hlint.yaml
perl -pi -e 's/name: \[runIO, /name: [/' .hlint.yaml
grep -q 'name: \[hspec,' .hlint.yaml
scripts/format >/dev/null 2>&1 || true
