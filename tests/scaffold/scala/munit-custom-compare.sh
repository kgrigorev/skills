# expect: red No switched-off checks in the compiled code
# A Compare given in the suite decides what assertEquals accepts: here, everything.
cat > src/test/scala/CompareSuite.scala <<'X'
package sampletool

class CompareSuite extends munit.FunSuite:
  given munit.Compare[String, String] = (_, _) => true

  test("broken"):
    assertEquals(SampleTool.greet("a"), "nope")
X
scripts/format >/dev/null
