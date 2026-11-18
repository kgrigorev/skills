# expect: red Build and test
# A suite declared as an object still runs and fails.
cat >> src/test/scala/SampleToolSuite.scala <<'EOF'

object BrokenSuite extends munit.FunSuite:
  test("broken"):
    assertEquals(SampleTool.greet("a"), "nope")
EOF
mise exec -- scala-cli fmt project.scala src >/dev/null
