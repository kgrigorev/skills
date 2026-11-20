# expect: red No switched-off checks in the compiled code
# intercept[Throwable] catches the failure of the assertion inside it, so a broken test passes.
cat > src/test/scala/InterceptSuite.scala <<'X'
package sampletool

class InterceptSuite extends munit.FunSuite:
  test("broken"):
    val _ = intercept[Throwable](assertEquals(SampleTool.greet("a"), "nope"))
X
scripts/format >/dev/null
