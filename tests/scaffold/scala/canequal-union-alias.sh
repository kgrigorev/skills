# expect: red No switched-off checks in the compiled code
# A type alias Int | Any: the alias check wants a top type right after "=".
cat > src/main/scala/X.scala <<'X'
package sampletool

/** x */
object X:
  /** t */
  type Top = Int | Any
  given CanEqual[Top, Top] = CanEqual.derived

  /** y */
  def same(a: Int, b: String): Boolean = a == b
X
mise exec -- scala-cli fmt project.scala src >/dev/null
