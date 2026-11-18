# expect: red No switched-off checks
# A multi-line HLint ignore-all comment in the test file hides a skipped test.
perl -0pi -e 's/shouldSatisfy\)/shouldSatisfy, xit)/; s/it "keeps one space between words"/xit "keeps one space between words"/' test/SampleToolSpec.hs
printf '\n{-\nHLINT ignore\n-}\n' >>test/SampleToolSpec.hs
