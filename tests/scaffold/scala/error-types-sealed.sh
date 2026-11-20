# expect: green
# A sealed error hierarchy, Either with left.map between layers, and an opaque type.
cat > src/main/scala/Money.scala <<'X'
package sampletool

/** Amounts of money in cents, read from text such as "12.50". */
object Money:

  /** Cents, kept apart from other Ints by the type checker. */
  opaque type Cents = Long

  /** Why an amount was rejected. */
  sealed trait AmountError derives CanEqual
  /** The text is not a decimal number. */
  final case class NotDecimal(text: String) extends AmountError
  /** More than two digits after the point. */
  final case class TooPrecise(text: String) extends AmountError

  /** Why a transfer was rejected. */
  enum TransferError derives CanEqual:
    case BadAmount(cause: AmountError)
    case SameAccount

  /** Reads an amount. */
  def cents(text: String): Either[AmountError, Cents] =
    text.trim.split('.').toList match
      case List(whole) => whole.toLongOption.map(_ * 100).toRight(NotDecimal(text))
      case List(whole, part) if part.length <= 2 =>
        (whole.toLongOption, s"${part}00".take(2).toLongOption) match
          case (Some(w), Some(p)) => Right(w * 100 + p)
          case _                  => Left(NotDecimal(text))
      case List(_, _) => Left(TooPrecise(text))
      case _          => Left(NotDecimal(text))

  /** Checks a transfer between two accounts. */
  def transfer(from: String, to: String, amount: String): Either[TransferError, Cents] =
    if from == to then Left(TransferError.SameAccount)
    else cents(amount).left.map(TransferError.BadAmount(_))

  /** The amount as a plain number of cents. */
  extension (amount: Cents) def toLong: Long = amount
X
cat > src/test/scala/MoneySuite.scala <<'X'
package sampletool

class MoneySuite extends munit.FunSuite:

  test("whole and fractional amounts are read in cents"):
    assertEquals(Money.cents("12.5").map(_.toLong), Right(1250L))

  test("three decimals are too precise"):
    assertEquals(Money.cents("1.234"), Left(Money.TooPrecise("1.234")))

  test("a bad amount is wrapped in the transfer error"):
    assertEquals(
      Money.transfer("a", "b", "x"),
      Left(Money.TransferError.BadAmount(Money.NotDecimal("x")))
    )
X
scripts/format >/dev/null
