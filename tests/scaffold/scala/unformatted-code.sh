# expect: red Format (scalafmt
# Code that scalafmt would change.
perl -pi -e 's/val trimmed = name.trim/val trimmed=name.trim/' src/main/scala/SampleTool.scala
grep -q 'trimmed=name' src/main/scala/SampleTool.scala
