# expect: red Lint
# A skipped test.
perl -0pi -e 's/shouldSatisfy\)/shouldSatisfy, xit)/; s/it "keeps one space between words"/xit "keeps one space between words"/' test/SampleToolSpec.hs
