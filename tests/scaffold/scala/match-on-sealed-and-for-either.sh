# expect: green
# Exhaustive matches, a for over Either and an approved new dependency-free option.
cat > src/main/scala/Totals.scala <<'EOF'
package sampletool

/** Adds up amounts given as text. */
object Totals:

  /** Why an amount could not be added. */
  enum Problem derives CanEqual:
    case NotANumber(text: String)
    case Negative(value: Int)

  /** Reads one amount. */
  def amount(text: String): Either[Problem, Int] =
    for
      value <- text.trim.toIntOption.toRight(Problem.NotANumber(text))
      checked <- if value < 0 then Left(Problem.Negative(value)) else Right(value)
    yield checked

  /** Describes a problem for the user. */
  def describe(problem: Problem): String = problem match
    case Problem.NotANumber(text) => s"not a number: $text"
    case Problem.Negative(value)  => s"negative: $value"

  /** The sum of all amounts, or the first problem. */
  def sum(texts: List[String]): Either[Problem, Int] =
    texts.foldLeft[Either[Problem, Int]](Right(0)) { (total, text) =>
      total.flatMap(sofar => amount(text).map(_ + sofar))
    }
EOF
cat >> src/test/scala/SampleToolSuite.scala <<'EOF'

  test("the sum stops at the first problem"):
    assertEquals(Totals.sum(List("1", "x", "-2")), Left(Totals.Problem.NotANumber("x")))

  test("a negative amount is described"):
    assertEquals(Totals.describe(Totals.Problem.Negative(-2)), "negative: -2")
EOF
mise exec -- scala-cli fmt project.scala src >/dev/null
