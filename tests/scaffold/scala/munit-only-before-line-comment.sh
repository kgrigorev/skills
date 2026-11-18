# expect: red No switched-off checks
# A line comment after the code does not hide the line from the scan.
perl -pi -e 's|test\("a blank name greets the world"\):|test("a blank name greets the world".only): // focus|' src/test/scala/SampleToolSuite.scala
grep -q '\.only): // focus' src/test/scala/SampleToolSuite.scala
