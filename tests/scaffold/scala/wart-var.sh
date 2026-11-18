# expect: red Build and test
# A var.
perl -pi -e 's/val trimmed = name.trim/var trimmed = name.trim/' src/main/scala/SampleTool.scala
grep -q 'var trimmed' src/main/scala/SampleTool.scala
