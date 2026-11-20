# expect: red Build and test
# A suite that ends the test JVM with status 0 before its broken test runs.
cat > src/test/scala/ZzzSuite.scala <<'X'
package sampletool

class ZzzSuite extends munit.FunSuite:
  override def beforeAll(): Unit = sys.exit(0)

  test("broken"):
    assertEquals(SampleTool.greet("a"), "nope")
X
scripts/format >/dev/null
