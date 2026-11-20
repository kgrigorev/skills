# expect: red Build and test
# xs(0) on a List.
cat > src/main/scala/X.scala <<'EOF'
package sampletool

/** x */
object X:
  /** y */
  def first(xs: List[Int]): Int = xs(0)
EOF
scripts/format >/dev/null
