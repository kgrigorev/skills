# expect: red No switched-off checks
# A type alias that hides Any in a CanEqual given.
cat > src/main/scala/X.scala <<'EOF'
package sampletool

/** x */
object X:
  /** t */
  type T = Any
  given CanEqual[T, T] = CanEqual.derived

  /** y */
  def same(a: Int, b: String): Boolean = a == b
EOF
mise exec -- scala-cli fmt project.scala src >/dev/null
