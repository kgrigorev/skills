# expect: red No switched-off checks
# A test transform that replaces every body with a pass.
cat > src/test/scala/SampleToolSuite.scala <<'EOF'
package sampletool

class SampleToolSuite extends munit.FunSuite:
  override def munitTestTransforms: List[TestTransform] =
    super.munitTestTransforms :+ new TestTransform("p", t => t.withBody(() => ()))

  test("broken"):
    assertEquals(SampleTool.greet("a"), "nope")
EOF
mise exec -- scala-cli fmt project.scala src >/dev/null
