# expect: red No switched-off checks
# A test tagged munit.Ignore.
perl -pi -e 's/test\("a blank name greets the world"\)/test("a blank name greets the world".tag(munit.Ignore))/' src/test/scala/SampleToolSuite.scala
grep -q 'munit.Ignore' src/test/scala/SampleToolSuite.scala
