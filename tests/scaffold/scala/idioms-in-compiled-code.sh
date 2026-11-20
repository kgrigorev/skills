# expect: green
# Idioms whose compiled form holds code the compiler adds: a for over tuples (x$1 @unchecked), a
# partial function, a val pattern on a tuple, generic case classes and enums with derives
# CanEqual, an alias that mentions Any but is not compared, try/finally and intercept in a test,
# and an enum in a test file (its compiled form holds a try/catch).
cat > src/main/scala/Ledger.scala <<'X'
package sampletool

/** Totals for a ledger of named amounts. */
object Ledger:

  /** Settings read from a file, before they are checked. */
  type Raw = Map[String, Any]

  /** A value with a label, compared by both. */
  final case class Labelled[A](label: String, value: A) derives CanEqual

  /** A tree of amounts. */
  enum Tree[A] derives CanEqual:
    case Leaf(value: A)
    case Node(left: Tree[A], right: Tree[A])

  /** Lines such as "rent" -> 3 repeated by their count. */
  def repeated(lines: List[(String, Int)]): List[String] =
    for
      (name, count) <- lines
      line = name * count
      if line.nonEmpty
    yield line

  /** The sum of every amount, with the names that held one. */
  def total(lines: List[(String, (Int, Int))]): (Int, List[String]) =
    lines.foldLeft((0, List.empty[String])) { case ((sum, names), (name, (a, b))) =>
      (sum + a + b, name :: names)
    }

  /** The two halves of a pair, added. */
  def add(pair: (Int, Int)): Int =
    val (a, b) = pair
    a + b

  /** The setting names, sorted. */
  def names(raw: Raw): List[String] = raw.keys.toList.sorted

  /** Sums a tree. */
  def sum(tree: Tree[Int]): Int = tree match
    case Tree.Leaf(value)       => value
    case Tree.Node(left, right) => sum(left) + sum(right)
X
cat > src/test/scala/LedgerSuite.scala <<'X'
package sampletool

class LedgerSuite extends munit.FunSuite:

  /** Which side of a pair a test reads. */
  enum Side derives CanEqual:
    case First, Second

  test("repeated lines keep their order"):
    assertEquals(Ledger.repeated(List("a" -> 2, "b" -> 0)), List("aa"))

  test("the total counts every amount"):
    assertEquals(Ledger.total(List("x" -> (1, 2), "y" -> (3, 4))), (10, List("y", "x")))

  test("labelled values compare by label and value"):
    assert(Ledger.Labelled("a", 1) == Ledger.Labelled("a", 1))
    assertEquals(Ledger.sum(Ledger.Tree.Node(Ledger.Tree.Leaf(1), Ledger.Tree.Leaf(2))), 3)

  test("setting names are sorted"):
    assertEquals(Ledger.names(Map[String, Any]("b" -> 1, "a" -> "x")), List("a", "b"))

  test("a word is not a number"):
    val error = intercept[NumberFormatException]("ten".toInt)
    assert(error.getMessage.nonEmpty)

  test("sides are distinct"):
    val side = Side.valueOf("First")
    try assertEquals(Ledger.add((1, 2)), 3)
    finally assertNotEquals(side, Side.Second)
X
scripts/format >/dev/null
