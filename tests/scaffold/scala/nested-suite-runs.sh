# expect: red Build and test
# A failing suite nested in an object.
cat > src/test/scala/Nested.scala <<'X'
package sampletool

object Nested:
  class BrokenSuite extends munit.FunSuite:
    test("broken"):
      assertEquals(SampleTool.greet("a"), "nope")
X
mise exec -- scala-cli fmt project.scala src >/dev/null
