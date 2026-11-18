# expect: red No switched-off checks
# A test marked .only hides the others.
perl -pi -e 's/test\("a blank name greets the world"\)/test("a blank name greets the world".only)/' src/test/scala/SampleToolSuite.scala
grep -q '.only' src/test/scala/SampleToolSuite.scala
