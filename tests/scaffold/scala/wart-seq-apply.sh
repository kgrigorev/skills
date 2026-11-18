# expect: red Build and test
# xs(0) on a List.
cat > src/main/scala/X.scala <<'EOF'
package sampletool

/** x */
object X:
  /** y */
  def first(xs: List[Int]): Int = xs(0)
EOF
mise exec -- scala-cli fmt project.scala src >/dev/null
