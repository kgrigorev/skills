# expect: red No switched-off checks
# A test that only checks outside CI.
cat > src/test/scala/SampleToolSuite.scala <<'EOF'
package sampletool

class SampleToolSuite extends munit.FunSuite:
  test("broken"):
    if !isCI then assertEquals(SampleTool.greet("a"), "nope")
EOF
mise exec -- scala-cli fmt project.scala src >/dev/null
