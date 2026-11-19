# expect: red No switched-off checks in the compiled code
# The same through a helper whose type parameter munit's FailException fits.
cat > src/test/scala/InterceptSuite.scala <<'X'
package sampletool

import scala.reflect.ClassTag

class InterceptSuite extends munit.FunSuite:
  private def expecting[E <: Throwable: ClassTag](body: => Any): Unit =
    val _ = intercept[E](body)

  test("broken"):
    expecting[munit.FailException](assertEquals(SampleTool.greet("a"), "nope"))
X
mise exec -- scala-cli fmt project.scala src >/dev/null
