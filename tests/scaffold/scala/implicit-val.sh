# expect: red Build and test
# implicit val instead of given.
cat > src/main/scala/X.scala <<'EOF'
package sampletool

/** x */
object X:
  /** n */
  implicit val n: Int = 1

  /** y */
  def y(using m: Int): Int = m
EOF
mise exec -- scala-cli fmt project.scala src >/dev/null
