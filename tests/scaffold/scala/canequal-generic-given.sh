# expect: red Build and test
# A generic CanEqual given for every pair of types.
cat > src/main/scala/X.scala <<'EOF'
package sampletool

/** x */
object X:
  given anyEq[A, B]: CanEqual[A, B] = CanEqual.derived

  /** y */
  def same(a: Int, b: String): Boolean = a == b
EOF
mise exec -- scala-cli fmt project.scala src >/dev/null
