# expect: red Build and test
# A property that fails for every input.
perl -pi -e 's/greet\(name\).contains\(name.trim\)/greet(name).isEmpty/' src/test/scala/SampleToolSuite.scala
grep -q 'greet(name).isEmpty' src/test/scala/SampleToolSuite.scala
