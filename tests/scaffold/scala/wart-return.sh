# expect: red Build and test
# return.
cat > src/main/scala/X.scala <<'EOF'
package sampletool

/** x */
object X:
  /** y */
  def y(n: Int): Int =
    if n > 0 then return n
    0
EOF
scripts/format >/dev/null
