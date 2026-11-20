# expect: red No switched-off checks in the compiled code
# A generic CanEqual given for every pair of types, in the current given syntax (Scala 3.9
# rejects the older `given anyEq[A, B]: CanEqual[A, B]`).
cat > src/main/scala/X.scala <<'X'
package sampletool

/** x */
object X:
  given [A, B] => CanEqual[A, B] = CanEqual.derived

  /** y */
  def same(a: Int, b: String): Boolean = a == b
X
scripts/format >/dev/null
