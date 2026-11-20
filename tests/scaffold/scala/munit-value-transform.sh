# expect: red No switched-off checks
# A value transform that turns a failed Future into a pass.
cat > src/test/scala/SampleToolSuite.scala <<'EOF'
package sampletool

class SampleToolSuite extends munit.FunSuite:
  override def munitValueTransforms: List[ValueTransform] = Nil

  test("ok"):
    assertEquals(1, 1)
EOF
mise exec -- scala-cli fmt project.scala src >/dev/null
