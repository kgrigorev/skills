# expect: red No switched-off checks
# A suite annotated @munit.IgnoreSuite.
cat > src/test/scala/SampleToolSuite.scala <<'EOF'
package sampletool

@munit.IgnoreSuite
class SampleToolSuite extends munit.FunSuite:
  test("broken"):
    assertEquals(SampleTool.greet("a"), "nope")
EOF
scripts/format >/dev/null
