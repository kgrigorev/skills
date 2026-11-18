# expect: green
# File names with digits, dashes, underscores and extra dots.
mkdir -p src/main/scala/io_v2 src/test/scala/io_v2
cat > src/main/scala/io_v2/Csv-Reader.v2.scala <<'EOF'
package sampletool.io_v2

/** Splits a CSV line into its fields. */
object CsvReader:

  /** The fields of `line`, trimmed. */
  def fields(line: String): List[String] = line.split(",", -1).toList.map(_.trim)
EOF
cat > src/test/scala/io_v2/Csv-Reader_2.Suite.scala <<'EOF'
package sampletool.io_v2

class CsvReaderSuite extends munit.FunSuite:

  test("empty fields are kept"):
    assertEquals(CsvReader.fields("a,,b"), List("a", "", "b"))
EOF
mise exec -- scala-cli fmt project.scala src >/dev/null
