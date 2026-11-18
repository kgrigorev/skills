# expect: red No switched-off checks
# A // scalafmt: { } comment changes the rules for one file.
cat > src/main/scala/X.scala <<'EOF'
package sampletool

// scalafmt: { maxColumn = 300 }
/** x */
object X:
  /** y */
  def y: Int = 2
EOF
mise exec -- scala-cli fmt project.scala src >/dev/null
