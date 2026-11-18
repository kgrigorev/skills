# expect: red Build and test
# A suite with a constructor parameter, which munit cannot create.
cat >> src/test/scala/SampleToolSuite.scala <<'EOF'

class BrokenSuite(n: Int) extends munit.FunSuite:
  test("broken"):
    assertEquals(SampleTool.greet("a"), n.toString)
EOF
mise exec -- scala-cli fmt project.scala src >/dev/null
