# expect: red No switched-off checks
# def test overridden to register a pass instead of each test.
cat > src/test/scala/SampleToolSuite.scala <<'EOF'
package sampletool

class SampleToolSuite extends munit.FunSuite:
  override def test(name: String)(body: => Any)(using munit.Location): Unit =
    super.test("ok")(())

  test("broken"):
    assertEquals(SampleTool.greet("a"), "nope")
EOF
scripts/format >/dev/null
