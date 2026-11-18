# expect: red No switched-off checks
# A // format: off comment makes scalafmt skip code.
cat > src/main/scala/X.scala <<'EOF'
package sampletool

/** x */
object X:
  // format: off
  /** y */
  def y  :  Int   =   2
  // format: on
EOF
mise exec -- scala-cli fmt project.scala src >/dev/null
