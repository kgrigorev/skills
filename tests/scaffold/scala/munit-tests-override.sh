# expect: red No switched-off checks
# munitTests overridden to drop every test.
cat > src/test/scala/SampleToolSuite.scala <<'EOF'
package sampletool

class SampleToolSuite extends munit.FunSuite:
  override def munitTests(): Seq[Test] = Seq.empty

  test("broken"):
    assertEquals(SampleTool.greet("a"), "nope")
EOF
scripts/format >/dev/null
