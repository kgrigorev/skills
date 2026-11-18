# expect: green
# A small helper with total lookups and a test.
cat > src/main/scala/Words.scala <<'EOF'
package sampletool

/** Small text helpers for the command line. */
object Words:

  /** The word at `index`, if there is one. `lift` is the total form of `words(index)`. */
  def at(words: List[String], index: Int): Option[String] = words.lift(index)

  /** Counts how often each word occurs. */
  def counts(words: List[String]): Map[String, Int] =
    words.groupMapReduce(identity)(_ => 1)(_ + _)

  /** Reads a count, if the text is a number. */
  def count(text: String): Option[Int] = text.trim.toIntOption
EOF
cat >> src/test/scala/SampleToolSuite.scala <<'EOF'

  test("a missing word is None"):
    assertEquals(Words.at(List("a"), 3), None)

  test("counts adds up repeated words"):
    assertEquals(Words.counts(List("a", "b", "a")), Map("a" -> 2, "b" -> 1))
EOF
mise exec -- scala-cli fmt project.scala src >/dev/null
