# expect: red No switched-off checks
# A block comment before the code does not hide the line from the scan: only lines that hold
# nothing but a comment are skipped. The comment sits inside the call so scalafmt keeps the line.
perl -pi -e 's|  test\("a blank name greets the world"\)|  test( /* focus */ "a blank name greets the world".only)|' src/test/scala/SampleToolSuite.scala
grep -q 'test( /\* focus \*/ "a blank name greets the world"\.only)' src/test/scala/SampleToolSuite.scala
