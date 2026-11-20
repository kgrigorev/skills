# expect: red No switched-off checks
# assume(false) skips the rest of a test.
cat > src/test/scala/SampleToolSuite.scala <<'EOF'
package sampletool

class SampleToolSuite extends munit.FunSuite:
  test("broken"):
    assume(false, "later")
    assertEquals(SampleTool.greet("a"), "nope")
EOF
scripts/format >/dev/null
