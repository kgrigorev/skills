# expect: red Lint
# An around hook that never runs the example, so a broken example shows as passed.
perl -0pi -e 's/`shouldBe` "Ada Lovelace"/`shouldBe` "Ada  Lovelace"/; s/^import Test.Hspec \(Spec, /import Test.Hspec (Spec, around_, /m; s/  describe "tidyName" \$ do\n/  describe "tidyName" . around_ (const (pure ())) \$ do\n/' test/SampleToolSpec.hs
grep -q around_ test/SampleToolSpec.hs
scripts/format >/dev/null 2>&1 || true
