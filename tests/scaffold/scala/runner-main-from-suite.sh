# expect: red No switched-off checks in the compiled code
# A suite that sorts first calls the real test runner on one good suite. The runner exits 0 with
# itself as the caller, before the broken test in this suite runs.
cat > src/test/scala/AaaSuite.scala <<'X'
package sampletool

class AaaSuite extends munit.FunSuite:
  scala.build.testrunner.DynamicTestRunner.main(
    Array("--test-framework=munit.Framework", "--test-only=sampletool.SampleToolSuite")
  )

  test("broken"):
    assertEquals(SampleTool.greet("a"), "nope")
X
mise exec -- scala-cli fmt project.scala src >/dev/null
