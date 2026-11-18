# expect: red Build and test
# asInstanceOf.
cat > src/main/scala/X.scala <<'EOF'
package sampletool

/** x */
object X:
  /** y */
  def y(a: Matchable): String = a.asInstanceOf[String]
EOF
mise exec -- scala-cli fmt project.scala src >/dev/null
