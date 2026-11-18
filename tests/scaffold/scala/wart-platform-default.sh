# expect: red Build and test
# toLowerCase with the machine locale.
cat > src/main/scala/X.scala <<'EOF'
package sampletool

/** x */
object X:
  /** y */
  def y(s: String): String = s.toLowerCase
EOF
mise exec -- scala-cli fmt project.scala src >/dev/null
