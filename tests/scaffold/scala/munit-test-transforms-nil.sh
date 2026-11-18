# expect: red No switched-off checks
# munitTestTransforms set to Nil.
cat > src/test/scala/SampleToolSuite.scala <<'EOF'
package sampletool

class SampleToolSuite extends munit.FunSuite:
  override def munitTestTransforms: List[TestTransform] = Nil

  test("ok"):
    assertEquals(1, 1)
EOF
mise exec -- scala-cli fmt project.scala src >/dev/null
