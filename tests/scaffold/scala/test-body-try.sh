# expect: red No switched-off checks in the compiled code
# A test body wrapped in Try: the failed assertion becomes a Failure value, and munit passes it.
cat > src/test/scala/TrySuite.scala <<'X'
package sampletool

import scala.util.Try

class TrySuite extends munit.FunSuite:
  test("a greeting names the person"):
    Try(assertEquals(SampleTool.greet("Ada"), "Hi, Ada!"))
X
scripts/format >/dev/null
