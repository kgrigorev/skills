# expect: red No switched-off checks in comments
# scalafmt also honours the IntelliJ-style // @formatter:off, which the format_off pattern misses.
cat > src/main/scala/X.scala <<'X'
package sampletool

/** x */
object X:
  // @formatter:off
  /** y */
  def y  :  Int   =   2
  // @formatter:on
X
