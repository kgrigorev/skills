# expect: red Build and test
# An unused private def.
cat > src/main/scala/X.scala <<'EOF'
package sampletool

/** x */
object X:
  private def unused(): Int = 1

  /** y */
  def y: Int = 2
EOF
mise exec -- scala-cli fmt project.scala src >/dev/null
