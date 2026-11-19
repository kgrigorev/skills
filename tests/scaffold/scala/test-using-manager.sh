# expect: red No switched-off checks in the compiled code
# Using.Manager returns the failure as a Try, and munit passes a test whose value is a Failure.
cat > src/test/scala/UsingSuite.scala <<'X'
package sampletool

import scala.util.Using

class UsingSuite extends munit.FunSuite:
  test("broken"):
    Using.Manager(_ => assertEquals(SampleTool.greet("a"), "nope"))
X
mise exec -- scala-cli fmt project.scala src >/dev/null
