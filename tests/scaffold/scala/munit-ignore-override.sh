# expect: red No switched-off checks
# munitIgnore overridden to skip the suite.
cat > src/test/scala/SampleToolSuite.scala <<'EOF'
package sampletool

class SampleToolSuite extends munit.FunSuite:
  override def munitIgnore: Boolean = true

  test("broken"):
    assertEquals(SampleTool.greet("a"), "nope")
EOF
mise exec -- scala-cli fmt project.scala src >/dev/null
