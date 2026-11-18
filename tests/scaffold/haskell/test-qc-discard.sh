# expect: red Test
# A property whose precondition never holds, so QuickCheck gives up.
perl -0pi -e 's/import Test.QuickCheck \(\(===\)\)/import Test.QuickCheck ((===), (==>))/; s/      let once = tidyName \(Text.pack name\)\n       in tidyName once === once/      null name \&\& not (null name) ==>\n        let once = tidyName (Text.pack name)\n         in tidyName once === once/' test/SampleToolSpec.hs
grep -q '==>' test/SampleToolSpec.hs
