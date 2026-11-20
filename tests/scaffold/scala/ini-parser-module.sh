# expect: green
# A dependency-free INI parser: regex extractors, foldLeft over lines, tailrec, Map lookups, f-strings.
cat > src/main/scala/Ini.scala <<'X'
package sampletool

import scala.annotation.tailrec
import scala.util.matching.Regex

/** Parses INI text into sections of key-value pairs. */
object Ini:

  /** A parsed file: section name to its settings. */
  type Sections = Map[String, Map[String, String]]

  private val Section: Regex = """\[([^\]]+)\]""".r
  private val Setting: Regex = """([^=]+)=(.*)""".r

  /** A line that is neither a section, a setting nor a comment. */
  final case class BadLine(number: Int, text: String) derives CanEqual

  /** Parses the whole text. Keys before any section go in the "" section. */
  def parse(text: String): Either[BadLine, Sections] =
    val start: Either[BadLine, (String, Sections)] = Right(("", Map.empty))
    text.linesIterator.zipWithIndex
      .foldLeft(start) { case (state, (line, index)) =>
        state.flatMap((section, sections) => step(section, sections, line.trim, index + 1))
      }
      .map(_._2)

  private def step(
      section: String,
      sections: Sections,
      line: String,
      number: Int
  ): Either[BadLine, (String, Sections)] = line match
    case ""                                  => Right((section, sections))
    case comment if comment.startsWith(";")  => Right((section, sections))
    case Section(name)                       => Right((name.trim, sections))
    case Setting(key, value) =>
      val current = sections.getOrElse(section, Map.empty)
      Right((section, sections.updated(section, current.updated(key.trim, value.trim))))
    case other => Left(BadLine(number, other))

  /** Follows "include" settings until a section has none, at most `limit` times. */
  @tailrec
  def resolve(sections: Sections, name: String, limit: Int = 10): String =
    sections.get(name).flatMap(_.get("include")) match
      case Some(next) if limit > 0 => resolve(sections, next, limit - 1)
      case _                       => name

  /** A one-line summary, such as "2 sections, 3 settings, 1.50 per section". */
  def summary(sections: Sections): String =
    val settings = sections.values.map(_.size).sum
    val perSection = if sections.isEmpty then 0.0 else settings.toDouble / sections.size
    f"${sections.size}%d sections, $settings%d settings, $perSection%.2f per section"
X
cat > src/test/scala/IniSuite.scala <<'X'
package sampletool

class IniSuite extends munit.FunSuite:

  test("settings land in their section"):
    assertEquals(
      Ini.parse("; top\n[db]\nhost = local\n"),
      Right(Map("db" -> Map("host" -> "local")))
    )

  test("a line without = is reported with its number"):
    assertEquals(Ini.parse("[a]\noops"), Left(Ini.BadLine(2, "oops")))

  test("include settings are followed"):
    val sections = Map("a" -> Map("include" -> "b"), "b" -> Map("x" -> "1"))
    assertEquals(Ini.resolve(sections, "a"), "b")
X
scripts/format >/dev/null
