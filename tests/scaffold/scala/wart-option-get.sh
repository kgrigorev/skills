# expect: red Build and test
# Option.get.
cat > src/main/scala/X.scala <<'EOF'
package sampletool

/** x */
object X:
  /** y */
  def y(o: Option[Int]): Int = o.get
EOF
mise exec -- scala-cli fmt project.scala src >/dev/null
