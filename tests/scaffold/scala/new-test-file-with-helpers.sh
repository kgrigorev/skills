# expect: green
# A second test file with a private helper and a fixture-like value.
cat > src/test/scala/GreetingSuite.scala <<'EOF'
package sampletool

class GreetingSuite extends munit.FunSuite:

  private val names = List("Ada", "  Grace  ", "Linus")

  private def greeted(name: String): Boolean = SampleTool.greet(name).startsWith("Hello, ")

  test("every name is greeted"):
    assert(names.forall(greeted))

  test("spaces around a name are dropped"):
    assertEquals(SampleTool.greet("  Grace  "), "Hello, Grace!")
EOF
scripts/format >/dev/null
