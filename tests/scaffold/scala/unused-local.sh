# expect: red Build and test
# An unused local val.
cat > src/main/scala/X.scala <<'EOF'
package sampletool

/** x */
object X:
  /** y */
  def y: Int =
    val unusedLocal = 3
    2
EOF
mise exec -- scala-cli fmt project.scala src >/dev/null
