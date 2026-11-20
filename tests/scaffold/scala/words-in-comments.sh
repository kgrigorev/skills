# expect: green
# Comments that use the words the switch-off scan looks for.
cat > src/main/scala/Filter.scala <<'EOF'
package sampletool

/** Picks the lines worth reading from a file. */
object Filter:

  // Ignore blank lines and lines that start with #. They carry no data.
  // A line may fail to parse; the caller decides, e.g. only count the good ones.
  // Flaky input, such as a half-written file, shows up as a parse error, not a crash.
  // The old version used @nowarn here; it is gone, and so is the unused import.

  /** The lines that hold data. */
  def dataLines(lines: List[String]): List[String] =
    lines.map(_.trim).filter(line => line.nonEmpty && !line.startsWith("#"))
EOF
cat >> src/test/scala/SampleToolSuite.scala <<'EOF'

  // Ignore the order of the checks below: each one stands alone. Tests must never be .only.
  test("comment and blank lines are dropped"):
    assertEquals(Filter.dataLines(List("# head", " ", "a")), List("a"))
EOF
scripts/format >/dev/null
