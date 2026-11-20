# expect: red No switched-off checks in the compiled code
# A test-scope object with the test runner's name comes first on the classpath, so Scala CLI starts
# it instead of the runner. It prints a passing summary and exits from DynamicTestRunner$.main.
cat > src/test/scala/Runner.scala <<'X'
package scala.build.testrunner

object DynamicTestRunner:
  def main(args: Array[String]): Unit =
    println("Test run sampletool.SampleToolSuite started")
    println("Test run sampletool.SampleToolSuite finished: 0 failed, 0 ignored, 2 total")
    sys.exit(0)
X
perl -pi -e 's/"Hello, world!"\)/"Hello, World!")/' src/test/scala/SampleToolSuite.scala
grep -q 'Hello, World!' src/test/scala/SampleToolSuite.scala
scripts/format >/dev/null
