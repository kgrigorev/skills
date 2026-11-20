# expect: green
# A new module with an enum, Either errors and a test suite.
cat > src/main/scala/Ledger.scala <<'EOF'
package sampletool

/** Parses ledger lines such as `2026-01-31,food,-12.50` into entries. */
object Ledger:

  /** Why a line could not be read. `derives CanEqual` lets tests compare errors with `==`. */
  enum ParseError derives CanEqual:
    case WrongFieldCount(line: String)
    case BadAmount(text: String)

  /** One booked amount. */
  final case class Entry(date: String, category: String, amount: BigDecimal) derives CanEqual

  /** Reads one line, or says why it cannot. */
  def parse(line: String): Either[ParseError, Entry] =
    line.split(",", -1).toList match
      case List(date, category, amount) =>
        amount.trim.toDoubleOption
          .map(value => Entry(date.trim, category.trim, BigDecimal(value)))
          .toRight(ParseError.BadAmount(amount))
      case _ => Left(ParseError.WrongFieldCount(line))

  /** Sums the amounts of the lines that parse. */
  def total(lines: List[String]): BigDecimal =
    lines.map(parse).collect { case Right(entry) => entry.amount }.sum
EOF
cat > src/test/scala/LedgerSuite.scala <<'EOF'
package sampletool

class LedgerSuite extends munit.FunSuite:

  test("a line with three fields parses"):
    assertEquals(
      Ledger.parse("2026-01-31, food, -12.5"),
      Right(Ledger.Entry("2026-01-31", "food", BigDecimal(-12.5)))
    )

  test("a line with two fields is an error"):
    assertEquals(Ledger.parse("a,b"), Left(Ledger.ParseError.WrongFieldCount("a,b")))

  test("the total skips lines that do not parse"):
    assertEquals(Ledger.total(List("d,c,1.5", "bad", "d,c,2")), BigDecimal(3.5))
EOF
scripts/format >/dev/null
