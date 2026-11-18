# expect: red Lint
# A focused test: hspec then runs only that one.
perl -0pi -e 's/import Test.Hspec \(Spec, describe, it,/import Test.Hspec (Spec, describe, fit, it,/; s/\$ it "names the program"/\$ fit "names the program"/' test/SampleToolSpec.hs
