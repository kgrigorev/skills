# expect: red Test
# A property that does not hold.
perl -0pi -e 's/in tidyName once === once/in once === Text.pack name/' test/SampleToolSpec.hs
