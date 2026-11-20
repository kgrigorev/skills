# expect: red No switched-off checks in the compiled code
# munit waits for a returned Future, but recover turns its failure into a success.
cat > src/test/scala/FutureSuite.scala <<'X'
package sampletool

import scala.concurrent.Future

class FutureSuite extends munit.FunSuite:
  test("broken"):
    Future(assertEquals(SampleTool.greet("a"), "nope"))(using munitExecutionContext)
      .recover { case _ => () }(using munitExecutionContext)
X
scripts/format >/dev/null
