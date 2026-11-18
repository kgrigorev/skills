# expect: green
# Domain names and strings that contain the words the scan looks for.
cat > src/main/scala/Rules.scala <<'EOF'
package sampletool

/** What the tool does with a ledger line, chosen by the user's rules. */
enum Action derives CanEqual:
  case Keep, Ignore, Fail

/** A label the user puts on an entry, such as "food". */
final case class Tag(name: String) derives CanEqual

/** Reads the user's rules. */
object Rules:

  /** Help text for the rules file. */
  val help: String = "Each rule is a pattern and one of: keep, ignore, fail. Lines marked ignore are skipped."

  /** The action named by `word`. */
  def action(word: String): Option[Action] = word.trim match
    case "keep"   => Some(Action.Keep)
    case "ignore" => Some(Action.Ignore)
    case "fail"   => Some(Action.Fail)
    case _        => None

  /** The tags in a comma-separated list. */
  def tags(text: String): List[Tag] =
    text.split(",").toList.map(_.trim).filter(_.nonEmpty).map(Tag(_))

  /** A setting from a `key=value` list, like a Java property. */
  def property(settings: Map[String, String], key: String): Option[String] = settings.get(key)
EOF
cat >> src/test/scala/SampleToolSuite.scala <<'EOF'

  test("the word ignore names the Ignore action"):
    assertEquals(Rules.action("ignore"), Some(Action.Ignore))

  test("a failing rule is the Fail action"):
    assertEquals(Rules.action(" fail "), Some(Action.Fail))

  test("tags are split on commas"):
    assertEquals(Rules.tags("food, rent,"), List(Tag("food"), Tag("rent")))
EOF
mise exec -- scala-cli fmt project.scala src >/dev/null
