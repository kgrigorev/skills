# expect: red No switched-off checks
# munit.Fail added with copy on the suite's own String conversion, without the word TestOptions.
cat > src/test/scala/SampleToolSuite.scala <<'EOF'
package sampletool

class SampleToolSuite extends munit.FunSuite:
  test(testOptionsFromString("broken").copy(tags = Set(munit.Fail))):
    assertEquals(SampleTool.greet("a"), "nope")
EOF
mise exec -- scala-cli fmt project.scala src >/dev/null
