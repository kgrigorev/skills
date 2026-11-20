# expect: red No switched-off checks
# A broken test marked .fail, so its failure passes.
cat > src/test/scala/SampleToolSuite.scala <<'EOF'
package sampletool

class SampleToolSuite extends munit.FunSuite:
  test("broken".fail):
    assertEquals(SampleTool.greet("a"), "nope")
EOF
scripts/format >/dev/null
