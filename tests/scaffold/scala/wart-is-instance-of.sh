# expect: red Build and test
# isInstanceOf.
cat > src/main/scala/X.scala <<'EOF'
package sampletool

/** x */
object X:
  /** y */
  def y(a: Matchable): Boolean = a.isInstanceOf[String]
EOF
mise exec -- scala-cli fmt project.scala src >/dev/null
