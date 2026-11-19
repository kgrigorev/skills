# expect: red Build and test: test results
# A test that throws JUnit's AssumptionViolatedException without assume or throw: munit reports it
# as skipped, but the suite summary still says 0 ignored.
cat > src/test/scala/SkipSuite.scala <<'X'
package sampletool

class SkipSuite extends munit.FunSuite:
  test("broken"):
    java.util.Optional.empty[Unit]().orElseThrow(() => org.junit.AssumptionViolatedException("later"))
    assertEquals(SampleTool.greet("a"), "nope")
X
mise exec -- scala-cli fmt project.scala src >/dev/null
