# expect: red Build and test
# An Array interpolated into a string.
cat > src/main/scala/X.scala <<'EOF'
package sampletool

/** x */
object X:
  /** y */
  def y: String = Array(1, 2).toString
EOF
mise exec -- scala-cli fmt project.scala src >/dev/null
