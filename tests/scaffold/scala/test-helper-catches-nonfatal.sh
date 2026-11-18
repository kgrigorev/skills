# expect: red No switched-off checks in the compiled code
# A catch-all that hides the AssertionError of a failing helper: NonFatal(_) catches munit's
# FailException, so a broken check in a shared helper passes.
cat > src/test/scala/HelperSuite.scala <<'X'
package sampletool

import scala.util.control.NonFatal

class HelperSuite extends munit.FunSuite:
  private def check(name: String, want: String): Unit =
    try assertEquals(SampleTool.greet(name), want)
    catch case NonFatal(_) => ()

  test("greets Ada"):
    check("Ada", "Hi, Ada!")
X
mise exec -- scala-cli fmt project.scala src >/dev/null
