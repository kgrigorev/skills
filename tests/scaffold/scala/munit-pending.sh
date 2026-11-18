# expect: red No switched-off checks
# A test marked .pending.
perl -pi -e 's/test\("a blank name greets the world"\)/test("a blank name greets the world".pending)/' src/test/scala/SampleToolSuite.scala
grep -q '.pending' src/test/scala/SampleToolSuite.scala
