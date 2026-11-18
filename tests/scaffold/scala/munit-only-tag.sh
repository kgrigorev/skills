# expect: red No switched-off checks
# A test tagged munit.Only.
cat > src/test/scala/SampleToolSuite.scala <<'EOF'
package sampletool

class SampleToolSuite extends munit.FunSuite:
  test(munit.TestOptions("ok").tag(munit.Only)):
    assertEquals(1, 1)

  test("broken"):
    assertEquals(SampleTool.greet("a"), "nope")
EOF
mise exec -- scala-cli fmt project.scala src >/dev/null
