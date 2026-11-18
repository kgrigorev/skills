# expect: red Lint
# A test marked pending instead of written.
perl -0pi -e 's/import Test.Hspec \(Spec, describe, it,/import Test.Hspec (Spec, describe, it, pending,/' test/SampleToolSpec.hs
cat >>test/SampleToolSpec.hs <<'HS'

    it "handles tabs" pending
HS
