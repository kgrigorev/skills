# expect: red Build and test
# A call to a deprecated method.
cat > src/main/scala/X.scala <<'EOF'
package sampletool

/** x */
object X:
  @deprecated("use z", "1.0")
  private def old: Int = 1

  /** y */
  def y: Int = old
EOF
mise exec -- scala-cli fmt project.scala src >/dev/null
