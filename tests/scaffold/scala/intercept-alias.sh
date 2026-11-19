# expect: red No switched-off checks in the compiled code
# The same through an alias of java.lang.AssertionError.
cat > src/test/scala/InterceptSuite.scala <<'X'
package sampletool

class InterceptSuite extends munit.FunSuite:
  type Expected = java.lang.AssertionError

  test("broken"):
    val _ = intercept[Expected](assertEquals(SampleTool.greet("a"), "nope"))
X
mise exec -- scala-cli fmt project.scala src >/dev/null
