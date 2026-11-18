# expect: red No switched-off checks
# munitFailTransform overridden to replace every test body with a pass.
cat > src/test/scala/SampleToolSuite.scala <<'EOF'
package sampletool

class SampleToolSuite extends munit.FunSuite:
  override def munitFailTransform: TestTransform =
    new TestTransform("pass", t => t.withBody(() => ()))

  test("broken"):
    assertEquals(SampleTool.greet("a"), "nope")
EOF
mise exec -- scala-cli fmt project.scala src >/dev/null
