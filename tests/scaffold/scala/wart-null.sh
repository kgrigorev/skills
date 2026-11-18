# expect: red Build and test
# null.
cat > src/main/scala/X.scala <<'EOF'
package sampletool

/** x */
object X:
  /** y */
  def y: String | Null = null
EOF
mise exec -- scala-cli fmt project.scala src >/dev/null
