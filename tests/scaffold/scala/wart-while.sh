# expect: red Build and test
# while.
cat > src/main/scala/X.scala <<'EOF'
package sampletool

/** x */
object X:
  /** y */
  def y(n: Int): Int =
    while n > 10 do println(n)
    n
EOF
scripts/format >/dev/null
