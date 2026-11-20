# expect: red Build and test
# xs.updated(i, x) on a List.
cat > src/main/scala/X.scala <<'EOF'
package sampletool

/** x */
object X:
  /** y */
  def y(xs: List[Int]): List[Int] = xs.updated(5, 0)
EOF
scripts/format >/dev/null
