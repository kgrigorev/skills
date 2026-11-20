# expect: green
# A domain field named "unused" after a comma: seats used and unused in a booking.
cat > src/main/scala/Seats.scala <<'X'
package sampletool

/** How many seats of a booking are taken. */
final case class Seats(used: Int, unused: Int) derives CanEqual:
  /** All seats of the booking. */
  def total: Int = used + unused

/** Books seats. */
object Seats:
  /** Takes `n` more seats, if there are enough left. */
  def take(seats: Seats, n: Int): Option[Seats] =
    Option.when(n <= seats.unused)(seats.copy(used = seats.used + n, unused = seats.unused - n))
X
cat >> src/test/scala/SampleToolSuite.scala <<'X'

  test("taking seats moves them from unused to used"):
    assertEquals(Seats.take(Seats(1, 3), 2), Some(Seats(3, 1)))
X
scripts/format >/dev/null
