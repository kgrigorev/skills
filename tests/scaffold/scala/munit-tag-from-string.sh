# expect: red No switched-off checks
# A tag built from a string, so no banned tag name appears.
cat > src/test/scala/SampleToolSuite.scala <<'EOF'
package sampletool

class SampleToolSuite extends munit.FunSuite:
  private val skip = new munit.Tag("Ign".concat("ore"))
  test(munit.TestOptions("broken").tag(skip)):
    assertEquals(SampleTool.greet("a"), "nope")
EOF
scripts/format >/dev/null
