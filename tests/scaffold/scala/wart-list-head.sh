# expect: red Build and test
# List.head.
perl -pi -e 's/val trimmed = name.trim/val trimmed = name.trim.split(" ").toList.head/' src/main/scala/SampleTool.scala
grep -q 'toList.head' src/main/scala/SampleTool.scala
