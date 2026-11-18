# expect: red No switched-off checks
# munit.Fail added through .tag taken as a function value, without the word TestOptions or
# ".tag(". (TestOptions.copy, the older form of this attack, is private in munit 1.3.)
cat > src/test/scala/SampleToolSuite.scala <<'X'
package sampletool

class SampleToolSuite extends munit.FunSuite:
  private val broken = "broken".tag

  test(broken(munit.Fail)):
    assertEquals(SampleTool.greet("a"), "nope")
X
mise exec -- scala-cli fmt project.scala src >/dev/null
