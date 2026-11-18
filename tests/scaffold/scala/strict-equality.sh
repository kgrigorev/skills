# expect: red Build and test
# == between Int and String.
cat > src/main/scala/X.scala <<'EOF'
package sampletool

/** x */
object X:
  /** y */
  def same(a: Int, b: String): Boolean = a == b
EOF
mise exec -- scala-cli fmt project.scala src >/dev/null
