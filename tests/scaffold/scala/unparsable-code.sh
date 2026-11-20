# expect: red Format (scalafmt
# expect-output: illegal start of simple expression
# A file scalafmt cannot parse. `scalafmt --check` reports the parse error but exits 0, so the
# format gate passed and only the compiler stopped it. Code that the compiler accepts and scalafmt
# cannot parse would then skip formatting. The gate fails on a parse error itself.
cat >src/main/scala/Broken.scala <<'SCALA'
package sampletool

object Broken:
  def value: Int = (((
SCALA
