# expect: red No switched-off checks
# A broken test marked .flaky.
cat > src/test/scala/SampleToolSuite.scala <<'EOF'
package sampletool

class SampleToolSuite extends munit.FunSuite:
  test("broken".flaky):
    assertEquals(SampleTool.greet("a"), "nope")
EOF
scripts/format >/dev/null
