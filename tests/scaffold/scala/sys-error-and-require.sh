# expect: red No switched-off checks in the compiled code
# Throwing without the throw keyword: sys.error and require in library code.
cat > src/main/scala/Port.scala <<'X'
package sampletool

/** Reads a port number. */
object Port:
  /** The port in text, or an exception. */
  def parse(text: String): Int =
    val port = text.trim.toIntOption.getOrElse(sys.error(s"not a number: $text"))
    require(port > 0 && port < 65536, s"out of range: $port")
    port
X
cat >> src/test/scala/SampleToolSuite.scala <<'X'

  test("a port parses"):
    assertEquals(Port.parse(" 80 "), 80)
X
scripts/format >/dev/null
