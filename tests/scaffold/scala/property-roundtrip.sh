# expect: green
# A property suite with a custom generator, a given Arbitrary, a round-trip law and labels.
cat > src/main/scala/Csv.scala <<'X'
package sampletool

/** Writes and reads one CSV row, quoting fields that need it. */
object Csv:

  /** The row as one line. */
  def write(fields: List[String]): String = fields.map(quote).mkString(",")

  private def quote(field: String): String =
    if field.exists(c => c == ',' || c == '"' || c == '\n') then
      "\"" + field.replace("\"", "\"\"") + "\""
    else field

  /** The fields of a line written by `write`. */
  def read(line: String): List[String] =
    val (fields, current, _) =
      line.foldLeft((Vector.empty[String], "", false)) { case ((done, field, quoted), c) =>
        (c, quoted) match
          case ('"', true) if field.endsWith("\"\"") => (done, field.dropRight(1), true)
          case ('"', _)                               => (done, field.appended(c), !quoted)
          case (',', false)                           => (done :+ unquote(field), "", false)
          case _                                      => (done, field.appended(c), quoted)
      }
    (fields :+ unquote(current)).toList

  private def unquote(field: String): String =
    if field.length >= 2 && field.startsWith("\"") && field.endsWith("\"") then
      field.drop(1).dropRight(1).replace("\"\"", "\"")
    else field
X
cat > src/test/scala/CsvPropertySuite.scala <<'X'
package sampletool

import munit.ScalaCheckSuite
import org.scalacheck.{Arbitrary, Gen}
import org.scalacheck.Prop.{forAll, propBoolean}

class CsvPropertySuite extends ScalaCheckSuite:

  override def scalaCheckInitialSeed: String = "TO7zgUWdv-WPJuetViT8r85tY3TprSjGhdyoESCTTkI="

  private val field: Gen[String] = Gen.listOf(Gen.oneOf(Gen.alphaNumChar, Gen.oneOf(',', ' '))).map(_.mkString)

  given Arbitrary[List[String]] = Arbitrary(Gen.nonEmptyListOf(field))

  property("reading a written row gives the fields back"):
    forAll { (fields: List[String]) =>
      (Csv.read(Csv.write(fields)) == fields) :| s"line: ${Csv.write(fields)}"
    }

  test("a field with a comma is quoted"):
    assertEquals(Csv.write(List("a,b", "c")), "\"a,b\",c")
X
mise exec -- scala-cli fmt project.scala src >/dev/null
