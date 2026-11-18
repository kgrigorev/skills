# expect: red Build and test
# A suite with no tests: munit reports it as ignored and exits 0.
printf 'package sampletool\n\nclass SampleToolSuite extends munit.FunSuite\n' > src/test/scala/SampleToolSuite.scala
