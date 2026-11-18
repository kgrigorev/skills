# expect: red No switched-off checks
# A broken test tagged munit.Fail through TestOptions: an expected failure passes.
cat > src/test/scala/SampleToolSuite.scala <<'EOF'
package sampletool

class SampleToolSuite extends munit.FunSuite:
  test(munit.TestOptions("broken").tag(munit.Fail)):
    assertEquals(SampleTool.greet("a"), "nope")
EOF
mise exec -- scala-cli fmt project.scala src >/dev/null
