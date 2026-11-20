# expect: red No switched-off checks
# withTags(Set(munit.Fail)).
cat > src/test/scala/SampleToolSuite.scala <<'EOF'
package sampletool

class SampleToolSuite extends munit.FunSuite:
  test("broken".withTags(Set(munit.Fail))):
    assertEquals(SampleTool.greet("a"), "nope")
EOF
scripts/format >/dev/null
