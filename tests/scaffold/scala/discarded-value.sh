# expect: red Build and test
# A pure expression whose value is dropped.
cat > src/main/scala/X.scala <<'EOF'
package sampletool

/** x */
object X:
  /** y */
  def y: Int =
    List(1).map(_ + 1)
    2
EOF
mise exec -- scala-cli fmt project.scala src >/dev/null
