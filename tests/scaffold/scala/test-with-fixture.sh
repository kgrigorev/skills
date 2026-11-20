# expect: green
# A test with a FunFixture, a clue and assertNotEquals.
cat > src/test/scala/FixtureSuite.scala <<'EOF'
package sampletool

class FixtureSuite extends munit.FunSuite:

  private val names = FunFixture[List[String]](setup = _ => List("Ada", "Grace"), teardown = _ => ())

  names.test("each name gets its own greeting"): list =>
    val greetings = list.map(SampleTool.greet)
    assertEquals(clue(greetings).distinct.size, list.size)

  test("a name is not the world"):
    assertNotEquals(SampleTool.greet("Ada"), SampleTool.greet(""))
EOF
mise exec -- scala-cli fmt project.scala src >/dev/null
