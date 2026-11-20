# expect: red Build and test: test results
# A shutdown hook halts with status 0 after the test runner's exit(1), so scala-cli exits 0 though
# a test failed. The runner's exit record says exit(1), and the summary says 1 failed.
cat > src/test/scala/HookSuite.scala <<'X'
package sampletool

class HookSuite extends munit.FunSuite:
  locally:
    val _ = sys.addShutdownHook(Runtime.getRuntime.halt(0))

  test("broken"):
    assertEquals(SampleTool.greet("a"), "nope")
X
scripts/format >/dev/null
