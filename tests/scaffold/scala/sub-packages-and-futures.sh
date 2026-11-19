# expect: green
# Sub-packages, in one clause or two, and the test forms the new bans must keep: a returned Future,
# Future.failed as an input, and intercept of the exception the code throws.
mkdir -p src/main/scala/parse
cat > src/main/scala/parse/Numbers.scala <<'X'
package sampletool
package parse

import scala.concurrent.ExecutionContext
import scala.concurrent.Future

/** Reads numbers. */
object Numbers:
  /** The number in `text`, or 0. */
  def orZero(text: String): Int = text.toIntOption.getOrElse(0)

  /** The value of `number`, or 0 when it failed. */
  def settle(number: Future[Int])(using ExecutionContext): Future[Int] =
    number.recover { case _: NumberFormatException => 0 }
X
cat > src/test/scala/NumbersSuite.scala <<'X'
package sampletool.parse

import scala.concurrent.Future

class NumbersSuite extends munit.FunSuite:
  test("a word reads as 0"):
    assertEquals(Numbers.orZero("ten"), 0)

  test("a failed number settles to 0"):
    given scala.concurrent.ExecutionContext = munitExecutionContext
    Numbers.settle(Future.failed(NumberFormatException("ten"))).map(n => assertEquals(n, 0))

  test("toInt throws on a word"):
    val error = intercept[NumberFormatException]("ten".toInt)
    assert(error.getMessage.nonEmpty)
X
mise exec -- scala-cli fmt project.scala src >/dev/null
