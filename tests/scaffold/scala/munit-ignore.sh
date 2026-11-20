# expect: red No switched-off checks
# A test marked .ignore.
perl -pi -e 's/test\("a blank name greets the world"\)/test("a blank name greets the world".ignore)/' src/test/scala/SampleToolSuite.scala
grep -q '.ignore' src/test/scala/SampleToolSuite.scala
