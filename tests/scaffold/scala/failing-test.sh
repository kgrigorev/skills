# expect: red Build and test
# A failing assertion.
perl -pi -e 's/"Hello, world!"\)/"Hello, World!")/' src/test/scala/SampleToolSuite.scala
grep -q 'Hello, World!' src/test/scala/SampleToolSuite.scala
